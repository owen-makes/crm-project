# create_table "holdings"
#   t.decimal "quantity", precision: 18, scale: 8
#   t.decimal "purchase_price", precision: 19, scale: 4
#   t.bigint "portfolio_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.uuid "security_id"
#   t.bigint "currency_id"
class Holding < ApplicationRecord
  belongs_to :portfolio
  belongs_to :security
  validates :quantity, :purchase_price, :security, presence: true



  # Returns the current market value of the holding
  def current_value(as_of_date = Date.today)
    # Get the most recent price before or on the given date
    security.current_value
  end

  # Returns what percentage of the portfolio's total value this holding represents
  def percentage_of_portfolio(as_of_date = Date.today)
    portfolio_value = portfolio.holdings.sum { |h| h.current_value(as_of_date) }

    # Avoid division by zero
    return 0 if portfolio_value.zero?

    (current_value(as_of_date) * quantity / portfolio_value) * 100
  end

  # Returns the profit or loss in absolute terms (current value - cost basis)
  def profit_loss
    security.current_value - purchase_price
  end

  def cost_basis
    purchase_price * quantity
  end

  # Returns the profit or loss as a percentage of the purchase price
  def profit_loss_percentage
    # Avoid division by zero
    return 0 if purchase_price.zero?

    (profit_loss / purchase_price) * 100
  end
end
