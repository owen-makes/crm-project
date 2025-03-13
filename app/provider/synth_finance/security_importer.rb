# app/services/synth_finance/security_importer.rb
module SynthFinance
  class SecurityImporter
    def initialize
      @api_service = SynthFinance::ApiService.new
    end

    def import_securities(exchange_acronym = nil)
      securities_data = @api_service.get_exchange_securities(exchange_acronym)
      return nil unless securities_data

      securities_data.each do |sec|
        create_or_update_security(sec)
      end
    end

    def import_currencies
      currencies = @api_service.get_currencies
      return nil unless currencies

      currencies.each do |curr|
        create_currency(curr)
      end
    end

    private

    # currencies:
    #   t.string "code"
    #   t.string "name"
    #   t.string "symbol"
    #   t.string "country"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    # end

    def create_currency(data)
      currency = Currency.find_by(code: data["currency_code"])

      if currency
       currency
      else
        currency = Currency.create(
          code: data["iso_code"],
          name: data["currency_name"],
          symbol: data["symbol"],
          country: data["country"]
        )
      end

      currency
    end

    def create_or_update_security(data)
      # Find the default currency or create it if not found
      currency = Currency.find_by(code: data["currency_code"]) ||
                Currency.create(code: data["currency_code"], name: data["currency_name"])

      security = Security.find_by(ticker: data["ticker"], exchange_mic: data["exchange_mic"])

      if security
        security.update(
          name: data["name"],
          country_code: data["country_code"],
          exchange_acronym: data["exchange_acronym"],
          logo_url: data["logo_url"],
          description: data["description"],
          security_type: map_security_type(data["security_type"]),
          currency_id: currency.id
        )
      else
        security = Security.create(
          ticker: data["ticker"],
          name: data["name"],
          country_code: data["country_code"],
          exchange_mic: data["exchange_mic"],
          exchange_acronym: data["exchange_acronym"],
          description: data["description"],
          logo_url: data["logo_url"],
          security_type: map_security_type(data["security_type"]),
          currency_id: currency.id
        )
      end

      security
    end

    # def create_security_price(security, price_data, date)
    #   security.security_prices.create(
    #     price: price_data["price"],
    #     date: date,
    #     # volume: price_data["volume"],
    #     # open: price_data["open"],
    #     # high: price_data["high"],
    #     # low: price_data["low"],
    #     # close: price_data["close"]
    #   )
    # end

    def map_security_type(api_type)
      # Map Synth Finance API security types to your enum types
      mapping = {
        "common stock" => "stock",
        "BOND" => "bond",
        "ETF" => "etf",
        "MUTUAL_FUND" => "mutual_fund",
        "OPTION" => "option",
        "FUTURE" => "future",
        "CS" => "cedear",
        "REIT" => "real_estate_trust",
        "COMMODITY" => "commodity"
      }

      mapping[api_type] || "stock" # Default to stock if unknown type
    end
  end
end
