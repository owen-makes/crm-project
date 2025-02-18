class Holding < ApplicationRecord
  belongs_to :portfolio
  validates :quantity, :cost_basis, :ticker, presence: true

  def current_value
    # Placeholder, will use real market price later
    mock_current_price = cost_basis / quantity * 1.1
    (quantity * mock_current_price).round(2)
  end

  def profit_loss
    (current_value - cost_basis).round(2)
  end

  def profit_loss_percentage
    (profit_loss / cost_basis * 100).round(2)
  end

  def percentage_of_portfolio
    (current_value / portfolio.total_value * 100).round(2)
  end
end
