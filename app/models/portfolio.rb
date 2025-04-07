# create_table "portfolios"
#   t.string "broker"
#   t.string "account_number"
#   t.string "name"
#   t.bigint "client_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.bigint "currency_id"
#   t.bigint "exchange_id", null: false
#   t.string "country"
#   t.index ["client_id"], name: "index_portfolios_on_client_id"
#   t.index ["currency_id"], name: "index_portfolios_on_currency_id"
#   t.index ["exchange_id"], name: "index_portfolios_on_exchange_id"
class Portfolio < ApplicationRecord
  belongs_to :client
  belongs_to :currency
  has_many :holdings, dependent: :destroy

  # Calculate the portfolio's total value using the provided bulk prices
  def total_value_with_bulk(prices_hash)
    holdings.sum do |holding|
      ticker = holding.security.ticker
      current_price = prices_hash[ticker] || holding.security.last_close
      holding.quantity * current_price
    end
  end

  # Return an array of metrics for each holding using bulk prices
  def holdings_with_bulk_metrics(prices_hash)
    # First, calculate current values per holding
    holding_values = holdings.map do |holding|
      ticker = holding.security.ticker
      current_price = prices_hash[ticker] || holding.security.last_close
      current_value = holding.quantity * current_price
      {
        holding: holding,
        current_price: current_price,
        current_value: current_value,
        profit_loss: (current_price - holding.purchase_price) * holding.quantity,
        profit_loss_percentage: holding.purchase_price > 0 ? ((current_price - holding.purchase_price) / holding.purchase_price * 100) : 0
      }
    end

    total_value = holding_values.sum { |h| h[:current_value] }
    # Add percentage data to each holding metric
    holding_values.each do |h|
      h[:percentage] = total_value > 0 ? (h[:current_value] / total_value * 100) : 0
    end

    holding_values
  end

  # Old methods below

  def total_value
    holdings.sum(&:current_value)
  end

  def holdings_with_metrics
    holdings.map do |holding|
      {
        holding: holding,
        current_value: holding.current_value,
        percentage: holding.percentage_of_portfolio,
        profit_loss: holding.profit_loss,
        profit_loss_percentage: holding.profit_loss_percentage
      }
    end
  end

  # Calculate total value converted to portfolio currency
  def total_value_in_portfolio_currency(as_of_date = Date.today)
    holdings.sum do |holding|
      value_in_security_currency = holding.current_value(as_of_date)

      # Convert to portfolio currency if different
      if holding.security.currency_id != self.currency_id
        exchange_rate = ExchangeRate.where(
          base_currency_id: holding.security.currency_id,
          target_currency_id: self.currency_id,
          date: as_of_date
        ).order(date: :desc).first&.rate || 1.0

        value_in_security_currency * exchange_rate
      else
        value_in_security_currency
      end
    end
  end

  # Calculate total cost basis of all holdings
  def total_cost_basis
    holdings.sum(&:cost_basis)
  end

  # Calculate total cost basis converted to portfolio currency
  def total_cost_basis_in_portfolio_currency
    holdings.sum do |holding|
      if holding.security.currency_id != self.currency_id
        # Get the exchange rate at the time of purchase
        # This is a simplification - ideally you'd use the exchange rate at the time of each transaction
        exchange_rate = ExchangeRate.where(
          base_currency_id: holding.security.currency_id,
          target_currency_id: self.currency_id
        ).order(date: :desc).first&.rate || 1.0

        holding.cost_basis * exchange_rate
      else
        holding.purchase_price
      end
    end
  end

  # Calculate total profit/loss in portfolio currency
  def total_profit_loss(as_of_date = Date.today)
    total_value_in_portfolio_currency(as_of_date) - total_cost_basis_in_portfolio_currency
  end

  # Calculate total profit/loss percentage
  def total_profit_loss_percentage(as_of_date = Date.today)
    return 0 if total_cost_basis_in_portfolio_currency.zero?

    (total_profit_loss(as_of_date) / total_cost_basis_in_portfolio_currency) * 100
  end

  # Get portfolio diversity - percentage allocation by security type
  def diversity_by_type(as_of_date = Date.today)
    total = total_value_in_portfolio_currency(as_of_date)
    return {} if total.zero?

    result = {}
    holdings.each do |holding|
      security_type = holding.security.security_type || "Unknown"
      result[security_type] ||= 0

      holding_value = holding.current_value(as_of_date)

      # Convert to portfolio currency if needed
      if holding.security.currency_id != self.currency_id
        exchange_rate = ExchangeRate.where(
          base_currency_id: holding.security.currency_id,
          target_currency_id: self.currency_id,
          date: as_of_date
        ).order(date: :desc).first&.rate || 1.0

        holding_value *= exchange_rate
      end

      result[security_type] += (holding_value / total) * 100
    end

    result
  end

  # Get portfolio diversity - percentage allocation by currency
  def diversity_by_currency(as_of_date = Date.today)
    total = total_value_in_portfolio_currency(as_of_date)
    return {} if total.zero?

    result = {}
    holdings.each do |holding|
      currency_code = holding.security.currency.code
      result[currency_code] ||= 0

      holding_value = holding.current_value(as_of_date)

      # Convert to portfolio currency for percentage calculation
      if holding.security.currency_id != self.currency_id
        exchange_rate = ExchangeRate.where(
          base_currency_id: holding.security.currency_id,
          target_currency_id: self.currency_id,
          date: as_of_date
        ).order(date: :desc).first&.rate || 1.0

        holding_value *= exchange_rate
      end

      result[currency_code] += (holding_value / total) * 100
    end

    result
  end

  def iso_country_code
    ISO3166::Country.find_country_by_any_name(country)&.alpha2
  end
end
