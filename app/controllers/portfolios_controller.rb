class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: %i[show edit update destroy]
  before_action :authorize_portfolio, only: %i[show edit update destroy]
  before_action :set_client, only: %i[new create]
  before_action :set_client_from_portfolio, only: [ :show, :edit ]

  def index
    if params[:client_id]
      @client = Client.find(params[:client_id])
      @portfolios = @client.portfolios
    else
      @portfolios = if current_user.admin?
                     Portfolio.joins(:client)
                     .where(clients: { team_id: current_user.managed_team })
      else
                     Portfolio.joins(:client)
                             .where(clients: { user_id: current_user.id })
      end
    end
  end

  def new
    @portfolio = @client.portfolios.build
  end

  def create
    @portfolio = @client.portfolios.build(portfolio_params)

    if @portfolio.save
      redirect_to client_portfolio_path(@client, @portfolio),
                  notice: "Portfolio successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    tickers = @portfolio.holdings
                        .joins(:security)
                        .pluck("securities.ticker")
                        .sort   # keep the stable sort for the cache key

    cache_key = "prices/#{Digest::SHA1.hexdigest(tickers.join)}"

    prices = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      Data912::ApiService.new.live_price_bulk(tickers)
    end

    @client = params[:client_id]
    @holdings = @portfolio.holdings

    # Compute holdings metrics using the bulk prices
    @holdings_metrics = @portfolio.holdings_with_bulk_metrics(prices)

    # Also compute the total portfolio value if needed
    @total_value = @portfolio.total_value_with_bulk(prices)

    @total_profit_loss = @holdings_metrics.sum { |h| h[:profit_loss] }
    @total_cost = @portfolio.total_cost_basis_in_portfolio_currency
    @total_profit_loss_percentage = @total_cost > 0 ? (@total_profit_loss / @total_cost) * 100 : 0
  end

  def edit
    @holdings = @portfolio.holdings # Fetch the holdings for the edit view
  end

  def update
    if @portfolio.update(portfolio_params)
      redirect_to @portfolio, notice: "Portfolio successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @portfolio.destroy
    redirect_to client_portfolios_path, notice: "Portfolio deleted."
  end

  private

  def set_portfolio
    @portfolio = Portfolio.includes(holdings: :security).find(params[:id])
  end

  def authorize_portfolio
    unless current_user.admin? || @portfolio.client.user == current_user
      redirect_to client_portfolios_path, alert: "You are not authorized to access this portfolio."
    end
  end

  def set_client
    @client = Client.find(params[:client_id])  # The client_id comes from the URL parameters
  end

  def set_client_from_portfolio
    @client = @portfolio.client
  end

  def portfolio_params
    params.require(:portfolio).permit(:broker, :account_number, :name, :client_id, :currency_id, :country)
  end
end
