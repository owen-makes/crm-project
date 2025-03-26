# app/provider/data912/api_service.rb
module Data912
  class ApiService
    include HTTParty
    base_uri "https://data912.com/"

    def initialize
      @options = {
        headers: {
          "Content-Type" => "application/json"
        }
      }
    end

    # Live Prices
    def live_mep
      self.class.get("/live/mep", @options)
    end

    def live_ccl
      self.class.get("/live/ccl", @options)
    end

    def live_price(ticker)
      security = Security.find_by(ticker: ticker)

      case security&.security_type
      when "stock"
        prices = live_arg_stocks
      when "cedear" || "etf"
        prices = live_arg_cedears
      when "bond"
        prices = live_arg_bonds
      else
        Rails.logger.error("Can't classify security or security not found")
        return nil
      end

      if prices
        price_data = prices.find { |item| item["symbol"] == ticker }
        price_data.nil? ? Rails.logger.error("Couldn't find price data for asset") : price_data["c"]
      else
        Rails.logger.warn("API error, fallback to last close for #{ticker}")
        security.last_close
      end
    end

    def live_price_bulk(arr = [])
      # Find securities in database from array of tickers
      securities_array = arr.map { |ticker| Security.find_by(ticker: ticker) }.compact

      # Return early if no securities found
      return {} if securities_array.empty?

      # Get unique security types
      sec_types = securities_array.map(&:security_type).uniq

      # Collect prices from corresponding endpoints
      security_prices = []
      security_prices += live_arg_stocks if sec_types.include?("stock")
      security_prices += live_arg_cedears if sec_types.include?("cedear") || sec_types.include?("etf")

      if sec_types.include?("bond")
        security_prices += live_arg_bonds
        security_prices += live_arg_notes
        security_prices += live_arg_corp
      end

      # Return early if no prices found
      return {} if security_prices.empty?

      # Create hash of prices
      prices_hash = {}
      securities_array.each do |sec|
        sec_price = security_prices.find { |item| item["symbol"] == sec.ticker }

        if sec_price
          prices_hash[sec.ticker] = sec_price["c"]
        else
          # Fallback to last close if no current price
          prices_hash[sec.ticker] = sec.last_close
          Rails.logger.warn("No current price found for #{sec.ticker}, using last close")
        end
      end

      prices_hash
    end

    def live_arg_stocks
      self.class.get("/live/arg_stocks", @options)
    end

    def live_arg_options
      self.class.get("/live/arg_options", @options)
    end

    def live_arg_cedears
      self.class.get("/live/arg_cedears", @options)
    end

    def live_arg_notes
      self.class.get("/live/arg_notes", @options)
    end

    def live_arg_corp
      self.class.get("/live/arg_corp", @options)
    end

    def live_arg_bonds
      self.class.get("/live/arg_bonds", @options)
    end

    def live_usa_adrs
      self.class.get("/live/usa_adrs", @options)
    end

    def live_usa_stocks
      self.class.get("/live/usa_stocks", @options)
    end

    # Historical
    def historical_stocks(ticker)
      self.class.get("/historical/stocks/#{ticker}", @options)
    end

    def historical_cedears(ticker)
      self.class.get("/historical/cedears/#{ticker}", @options)
    end

    def historical_bonds(ticker)
      self.class.get("/historical/bonds/#{ticker}", @options)
    end

    # EOD
    def eod_volatilities(ticker)
      self.class.get("/eod/volatilities/#{ticker}", @options)
    end

    def eod_option_chain(ticker)
      self.class.get("/eod/option_chain/#{ticker}", @options)
    end
  end
end
