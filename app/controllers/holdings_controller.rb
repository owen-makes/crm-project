class HoldingsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_client_and_portfolio
  before_action :set_holding, only: %i[show edit update destroy]
  before_action :authorize_portfolio
  before_action :load_securities, only: %i[new edit create update]

  def show
    # Individual holding details and metrics
  end

  def new
    @holding = @portfolio.holdings.build

    @items = @securities.map do |security|
      FancySelectComponent::Item.new(security.id, security.display_name, security.logo_url)
    end

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("securities_list",
          partial: "securities/securities_results",
          locals: { securities: @securities }
        )
      end
    end
  end

  def create
    @holding = @portfolio.holdings.build(holding_params)

    @items = @securities.map do |security|
      FancySelectComponent::Item.new(security.id, security.display_name, security.logo_url)
    end

    if @holding.save
      prepare_portfolio_metrics
      respond_to do |format|
        format.turbo_stream # Looks for create.turbo_stream.erb
        format.html { redirect_to portfolio_path(@portfolio), notice: "Holding created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end



  def edit
  end

  def update
    if @holding.update(holding_params)
      redirect_to portfolio_path(@portfolio),
                  notice: "Holding was successfully updated."
    else
      load_securities
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @holding.destroy
    redirect_to portfolio_path(@portfolio),
                notice: "Holding was successfully removed."
  end

  private

  def prepare_portfolio_metrics
    tickers          = @portfolio.holdings.map { |h| h.security.ticker }
    prices           = Data912::ApiService.new.live_price_bulk(tickers)
    @holdings_metrics = @portfolio.holdings_with_bulk_metrics(prices)

    @total_profit_loss = @holdings_metrics.sum { |h| h[:profit_loss] }
    @total_cost        = @portfolio.total_cost_basis_in_portfolio_currency
    @total_profit_loss_percentage =
      @total_cost.positive? ? (@total_profit_loss / @total_cost) * 100 : 0
  end

  def find_client_and_portfolio
    @portfolio = Portfolio.find(params[:portfolio_id])
    @client = @portfolio.client
  end

  def set_holding
    @holding = @portfolio.holdings.find(params[:id])
  end

  def authorize_portfolio
    unless current_user.admin? || @portfolio.client.user == current_user
      redirect_to root_path,
                  alert: "You are not authorized to access this holding."
    end
  end

  def load_securities
    if @portfolio.iso_country_code.present?
      @securities = Security.joins(:exchange)
                            .includes(:currency)
                            .where(exchanges: { country_code: @portfolio.iso_country_code })
                            .order(:ticker)
    else
      @securities = Security.includes(:currency).order(:ticker)
    end
  end

  def holding_params
    params.require(:holding).permit(:security_id, :quantity, :purchase_price)
  end
end
