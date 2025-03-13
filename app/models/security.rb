class Security < ApplicationRecord
  has_many :holdings
  has_many :security_prices, dependent: :destroy
  has_many :transactions
  belongs_to :default_currency, class_name: "Currency", foreign_key: "currency_id"
  validates :ticker, presence: true, uniqueness: true
  validates :name, presence: true

  # Enum for security types
  enum security_type: {
    stock: 0,
    bond: 1,
    etf: 2,
    mutual_fund: 3,
    option: 4,
    future: 5,
    cedear: 6,
    real_estate_trust: 7,
    commodity: 8
  }

  # Additional classification attributes
  attribute :sector, :string
  attribute :industry, :string
  attribute :market_cap_category, :string  # Small/Mid/Large cap

  # Optional deeper classification for specific types
  attribute :bond_type, :string  # Government, Corporate, Municipal
  attribute :option_type, :string  # Call, Put

  def current_value
    # Placeholder, will use real market price later
    mock_current_price = 100 * Random.rand(1.9)
    mock_current_price.round(2)
  end

  def latest_price
    security_prices.order(date: :desc).first
  end
end
