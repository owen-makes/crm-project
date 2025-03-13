class ExchangeRate < ApplicationRecord
  belongs_to :base_currency, class_name: "Currency"
  belongs_to :target_currency, class_name: "Currency"

  validates :base_currency, presence: true
  validates :target_currency, presence: true
  validates :rate, presence: true, numericality: { greater_than: 0 }
  validates :rate_type, presence: true, inclusion: { in: [ "MEP", "CCL", "Official" ] }

  validates :base_currency_id, uniqueness: { scope: [ :target_currency_id, :rate_type ] }

  def inverse_rate
    1.0 / rate if rate.present? && rate > 0
  end
end
