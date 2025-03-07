class Currency < ApplicationRecord
  has_many :portfolios
  has_many :holdings
  has_many :security_prices

  has_many :from_exchange_rates,
           class_name: "ExchangeRate",
           foreign_key: "base_currency_id"

  has_many :to_exchange_rates,
           class_name: "ExchangeRate",
           foreign_key: "target_currency_id"
end
