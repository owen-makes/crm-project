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
      current_price = prices_hash[ticker] || holding.security.last_close || 0.0
      current_value = holding.quantity * current_price
      {
        holding: holding,
        security_type: holding.security.security_type,
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

  # def total_value
  #   holdings.sum(&:current_value)
  # end

  # def holdings_with_metrics
  #   holdings.map do |holding|
  #     {
  #       holding: holding,
  #       current_value: holding.current_value,
  #       percentage: holding.percentage_of_portfolio,
  #       profit_loss: holding.profit_loss,
  #       profit_loss_percentage: holding.profit_loss_percentage
  #     }
  #   end
  # end

  # # Calculate total value converted to portfolio currency
  # def total_value_in_portfolio_currency(as_of_date = Date.today)
  #   holdings.sum(0.0) do |holding|
  #     value = holding.current_value(as_of_date) || 0.0

  #     holding.security.currency_id == currency_id ? value :
  #       value * fx_rate(holding.security.currency_id, on: as_of_date)
  #   end
  # end


  # # Calculate total cost basis of all holdings
  # def total_cost_basis
  #   holdings.sum(&:cost_basis)
  # end

  # # Calculate total cost basis converted to portfolio currency
  def total_cost_basis_in_portfolio_currency
    holdings.sum do |holding|
      cost = holding.cost_basis   # purchase_price * quantity
      holding.security.currency_id == currency_id ? cost :
        cost * fx_rate(holding.security.currency_id)  # purchase date ≠ stored → best‑available
    end
  end


  # # Calculate total profit/loss in portfolio currency
  # def total_profit_loss(as_of_date = Date.today)
  #   total_value_in_portfolio_currency(as_of_date) - total_cost_basis_in_portfolio_currency
  # end

  # # Calculate total profit/loss percentage
  # def total_profit_loss_percentage(as_of_date = Date.today)
  #   return 0 if total_cost_basis_in_portfolio_currency.zero?

  #   (total_profit_loss(as_of_date) / total_cost_basis_in_portfolio_currency) * 100
  # end

  # # Get portfolio percentage allocation by security type using previously fetched metrics
  def diversity_by_type(metrics)
    total_value = metrics.sum { |m| m[:current_value] }
    return {} if total_value.zero?

    metrics.each_with_object(Hash.new(0)) do |m, acc|
      type  = m[:security_type] || "Unknown"
      value = m[:current_value] || 0.0
      acc[type] += (value / total_value) * 100
    end
  end

  def iso_country_code
    ISO3166::Country.find_country_by_any_name(country)&.alpha2
  end

  def fx_rate(base_currency_id, on: Date.today)
    @fx_cache ||= {}
    key = [ base_currency_id, self.currency_id, on ]

    @fx_cache[key] ||= ExchangeRate
      .where(base_currency_id: base_currency_id,
             target_currency_id: self.currency_id,
             date: on)
      .order(date: :desc)
      .limit(1)
      .pick(:rate) || 1.0
  end
end
