namespace :data912 do
  desc "Update prices for all securities"
  task daily_update: :environment do
    api_service = Data912::ApiService.new
    securities = Security.where.not(security_price: nil)

    puts "Starting daily price update for #{securities.count} securities"
    updated_count = 0

    securities.each do |security|
      ticker = security.ticker
      security_type = security.security_type

      begin
        # Get the most recent price
        latest_price = nil

        case security_type
        when "stock"
          latest_price = api_service.latest_stock_price(ticker).parsed_response
        when "cedear" || "etf"
          latest_price = api_service.latest_cedear_price(ticker).parsed_response
        when "bond"
          latest_price = api_service.latest_bond_price(ticker).parsed_response
        else
          puts "Skipping #{ticker} - Not supported for #{security_type}"
          next
        end

        if latest_price && latest_price["date"] && latest_price["c"]
          date = Date.parse(latest_price["date"])

          security.security_prices.find_or_create_by(date: date) do |security_price|
            security_price.price = latest_price["c"]
          end

          updated_count += 1
          puts "Updated price for #{ticker}: #{latest_price["c"]} on #{date}"
        end
      rescue => e
        puts "Error updating #{ticker}: #{e.message}"
      end

      sleep 0.5 # Avoid rate limiting
    end

    puts "Completed daily update. Updated #{updated_count} securities."
  end
end
