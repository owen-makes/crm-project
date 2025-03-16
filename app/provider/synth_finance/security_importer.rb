# app/services/synth_finance/security_importer.rb
module SynthFinance
  class SecurityImporter
    def initialize
      @api_service = SynthFinance::ApiService.new
    end

    def import_exchange_and_securities(exchange_mic = nil)
      securities_data = @api_service.get_exchange_securities(exchange_mic)
      return nil unless securities_data

      exchange = create_exchange(securities_data["data"])
      puts "Exchange #{exchange.name} found"

      tickers = securities_data["data"]["tickers"]

      total_count = tickers.size
      puts "Found #{total_count} securities to import"
      puts "Exchange mic: #{exchange.mic_code}"
      puts "First ticker is: #{tickers.first}"
      puts "Last ticker is #{tickers.last}"

      tickers.each do |sec|
        asset = sec["symbol"]

        begin
          create_or_update_security(sec, exchange.mic_code)
        rescue => e
          puts "Error importing #{asset}: #{e.message}"
        end
      end
    end

    def import_currencies
      currencies = @api_service.get_currencies
      return nil unless currencies
      data = currencies["data"]
      puts data
      data.each do |curr|
        create_currency(curr)
      end
    end

    def import_exchanges
      exchanges = @api_service.get_exchanges
      return nil unless exchanges
      data = exchanges["data"]
      puts data
      data.each do |exch|
        create_exchange(exch)
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
      currency = Currency.find_by(code: data["iso_code"])

      if currency
       currency
      else
        currency = Currency.create(
          code: data["iso_code"],
          name: data["name"],
          symbol: data["symbol"],
          country: data["country"]
        )
      end

      currency
    end

    def create_exchange(data)
      exchange = Exchange.find_by(acronym: data["acronym"])

      if exchange
       exchange
      else
        exchange = Exchange.create(
          acronym: data["acronym"],
          name: data["name"],
          city: data["city"],
          country_code: data["country_code"],
          mic_code: data["mic_code"]
        )
      end

      exchange
    end


    def create_or_update_security(data, exchange_mic)
      # Find the default currency or create it if not found
      currency = Currency.find_by(code: data["currency"].downcase)


      exchange = Exchange.find_by(mic_code: exchange_mic)

      security = Security.find_by(ticker: data["symbol"], exchange_id: exchange&.id)

      if security
        security.update(
          name: data["name"],
          # logo_url: data["logo_url"],
          # description: data["description"],
          # security_type: map_security_type(data["security_type"]),
          currency_id: currency&.id,
          exchange_id: exchange&.id
        )
      else
        security = Security.create(
          ticker: data["symbol"],
          name: data["name"],
          # logo_url: data["logo_url"],
          # description: data["description"],
          # security_type: map_security_type(data["security_type"]),
          currency_id: currency&.id,
          exchange_id: exchange&.id
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
