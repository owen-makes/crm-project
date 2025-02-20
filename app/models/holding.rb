class Holding < ApplicationRecord
  belongs_to :portfolio
  validates :quantity, :cost_basis, :ticker, presence: true

  def current_value
    # Placeholder, will use real market price later
    mock_current_price = cost_basis * Random.rand(1.9)
    mock_current_price.round(2)
  end

  def profit_loss
    ((current_value - cost_basis)* quantity).round(2)
  end

  def profit_loss_percentage
    ((current_value / cost_basis - 1) * 100).round(2)
  end

  # wrong, fix later:!!
  def percentage_of_portfolio
    (((current_value) / portfolio.total_value) * 100).round(2)
  end
end
