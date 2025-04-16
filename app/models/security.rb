# create_table "securities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
#   t.string "ticker"
#   t.string "name"
#   t.string "logo_url"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.string "security_type"
#   t.bigint "currency_id", null: false
#   t.text "description"
#   t.bigint "exchange_id", null: false
#   t.index ["currency_id"], name: "index_securities_on_currency_id"
#   t.index ["exchange_id"], name: "index_securities_on_exchange_id"
# end
class Security < ApplicationRecord
  has_many :holdings
  has_many :security_prices, dependent: :destroy
  has_many :transactions
  belongs_to :currency
  belongs_to :exchange
  validates :ticker, presence: true, uniqueness: true
  validates :name, presence: true
  after_create :add_logo_url
  attribute :details, :json, default: {}

  # Enum for security types
  enum :security_type, {
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

  # TODO: Implement API calls for current value
  def current_value
    Rails.cache.fetch("security:#{ticker}:current_value", expires_in: 2.hours) do
      Data912::ApiService.new.live_price(ticker)
    end
  end


  def last_close
    price = self.security_prices.exists? ? self.security_prices.order(date: :desc).first&.price : 0
    price.zero? ? 0 : price.to_f
  end

  def display_name
    "#{ticker} - #{name} (#{currency.code.upcase})"
  end

  def issuer_type
    details["issuer_type"] if security_type == "bond"
  end

  private

  def add_logo_url
    self.logo_url = "https://logo.synthfinance.com/ticker/#{self.ticker}"
  end
end
