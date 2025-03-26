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
  end

  def create
    @holding = @portfolio.holdings.build(holding_params)

    if @holding.save
      redirect_to portfolio_path(@portfolio),
                  notice: "Holding was successfully created."
    else
      load_securities
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
    portfolio_currency = @portfolio.currency

    if portfolio_currency&.country_code.present?
      country_exchanges = Exchange.where(country_code: portfolio_currency.country_code)

      if country_exchanges.exists?
        @securities = Security.where(exchange_id: country_exchanges.pluck(:id))
                            .order(:name)
        return
      end
    end

    # Fallback to all securities
    @securities = Security.all.order(:name)
  end

  def holding_params
    params.require(:holding).permit(:security_id, :quantity, :purchase_price)
  end
end
