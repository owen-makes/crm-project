class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: %i[show edit update destroy]
  before_action :authorize_portfolio, only: %i[show edit update destroy]
  before_action :set_client, only: %i[new create]
  before_action :set_client_from_portfolio, only: [ :show, :edit ]

  def index
    if params[:client_id]
      @client = Client.find(params[:client_id])
      authorize_client(@client)
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
    @client = params[:client_id]
    @holdings = @portfolio.holdings
    @holdings_with_metrics = @portfolio.holdings_with_metrics
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
    @portfolio = Portfolio.find(params[:id])
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
    params.require(:portfolio).permit(:broker, :account_number, :name, :client_id, :currency_id)
  end
end
