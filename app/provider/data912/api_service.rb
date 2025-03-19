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
