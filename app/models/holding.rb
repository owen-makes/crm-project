class Holding < ApplicationRecord
  belongs_to :portfolio
  belongs_to :security
  validates :quantity, :cost_basis, :ticker, presence: true

  def calculate_cost_basis!
    # Sum of all purchase transactions divided by total quantity
    transactions = portfolio.transactions.where(security: security)

    self.total_cost_basis = transactions.sum do |t|
      t.quantity * t.price
    end

    self.average_cost_basis = total_cost_basis / total_quantity

    # Mark-to-market calculation
    current_price = security.current_price
    self.unrealized_gain_loss =
      (current_price - average_cost_basis) * total_quantity

    save
  end

  # wrong, fix later:!!
  def percentage_of_portfolio
    (((self.quantity * security.current_value) / portfolio.total_value) * 100).round(2)
  end
end
