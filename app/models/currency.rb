# t.string "code"
# t.string "name"
# t.string "symbol"
# t.string "country"
class Currency < ApplicationRecord
  has_many :portfolios
  has_many :securities

  has_many :base_exchange_rates,
           class_name: "ExchangeRate",
           foreign_key: "base_currency_id"

  has_many :target_exchange_rates,
           class_name: "ExchangeRate",
           foreign_key: "target_currency_id"

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :symbol, presence: true

  scope :base_currencies, -> { where(is_base: true) }

  def get_exchange_rate_to(currency_code, rate_type = "MEP")
    target_currency = Currency.find_by(code: currency_code)
    return nil unless target_currency

    rate = ExchangeRate.find_by(
      base_currency: self,
      target_currency: target_currency,
      rate_type: rate_type
    )

    # If direct rate not found, try inverse
    unless rate
      inverse_rate = ExchangeRate.find_by(
        base_currency: target_currency,
        target_currency: self,
        rate_type: rate_type
      )

      return inverse_rate.inverse_rate if inverse_rate
    end

    rate&.rate
  end


  def country_code
    # Map from country name to ISO code
    {
      "United States" => "US",
      "Canada" => "CA",
      "United Kingdom" => "GB",
      "Japan" => "JP",
      "Australia" => "AU",
      "Euro Zone" => "EU",
      "Switzerland" => "CH",
      "Argentina" => "AR"
    }[country]
  end
end
