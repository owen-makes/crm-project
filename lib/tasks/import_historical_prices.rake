namespace :data912 do
  desc "Import historical prices for securities"
  task import_prices: :environment do
    api_service = Data912::ApiService.new
    securities = Security.where.not(security_type: nil)
    puts "Beggining historical data import for #{securities.count} securities"

    securities.each do |security|
      ticker = security.ticker
      security_type = security.security_type

      begin
        case security_type
        when "stock"
          historical_data = api_service.historical_stocks(ticker).parsed_response
        when "cedear"
          historical_data = api_service.historical_cedears(ticker).parsed_response
        when "bond"
          historical_data = api_service.historical_bonds(ticker).parsed_response
        else
          puts "Skipping #{ticker} - Historical prices not supported for #{security_type}"
          next
        end

        if historical_data && historical_data.is_a?(Array)
          historical_data.each do |price_data|
            date = Date.parse(price_data["date"])
            if date >= 5.years.ago.to_date
              security.security_prices.find_or_create_by(date: date) do |security_price|
                security_price.price = price_data["c"]
              end
            end
          end
          puts "Imported historical prices for #{ticker}"
        else
          puts "Failed to retrieve historical data for #{ticker} or data format is incorrect."
        end
      rescue HTTParty::Error => e
        puts "Error fetching historical data for #{ticker}: #{e.message}"
      rescue Date::Error => date_error
        puts "Error parsing date for #{ticker}: #{date_error.message}"
      rescue => generic_error
        puts "Generic error for #{ticker}: #{generic_error.message}"
      end
      sleep 0.1 # Add a small delay to avoid rate limiting.
    end
  end
end
