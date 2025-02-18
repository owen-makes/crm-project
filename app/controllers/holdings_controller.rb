class HoldingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio
  before_action :set_holding, only: %i[show edit update destroy]
  before_action :authorize_portfolio

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
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @holding.destroy
    redirect_to portfolio_path(@portfolio),
                notice: "Holding was successfully removed."
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:portfolio_id])
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

  def holding_params
    params.require(:holding).permit(:ticker, :quantity, :cost_basis, :asset_type)
  end
end
