# app/services/synth_finance/api_service.rb
module SynthFinance
  class ApiService
    include HTTParty
    base_uri "https://api.synthfinance.com/"

    def initialize(api_key = nil)
      @api_key = api_key || ENV["SYNTH_FINANCE_API_KEY"]
      @options = {
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@api_key}"
        }
      }
    end

    def get_security_data(ticker, exchange_mic = nil)
      endpoint = "/tickers/#{ticker}"
      endpoint += "?mic_code=#{exchange_mic}" if exchange_mic.present?

      response = self.class.get(endpoint, @options)
      handle_response(response)
    end

    def get_exchange_securities(mic = "XBUE")
      endpoint = "/exchanges/#{mic}?include_tickers=true"

      response = self.class.get(endpoint, @options)
      handle_response(response)
    end

    def get_currencies
      endpoint = "/currencies"

      response = self.class.get(endpoint, @options)
      handle_response(response)
    end

    def get_exchanges(acronym = nil)
      endpoint = acronym ? "/exchanges/#{acronym}" : "/exchanges"

      response = self.class.get(endpoint, @options)
      handle_response(response)
    end

    private

    def handle_response(response)
      if response.success?
        response.parsed_response
      else
        Rails.logger.error("Synth Finance API Error: #{response.code} - #{response.message}")
        nil
      end
    end
  end
end
