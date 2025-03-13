# lib/tasks/synth_finance.rake
namespace :synth_finance do
  desc "Import all securities from the Argentine stock market (BYMA/BCBA)"
  task import_argentina_securities: :environment do
    api_service = SynthFinance::ApiService.new
    importer = SynthFinance::SecurityImporter.new
    exchange_acronym = "BCBA"

    puts "Fetching securities from Argentine stock market (MIC: #{exchange_acronym})..."

    # Fetch the list of all securities in the exchange
    securities_list = api_service.get_exchange_securities(exchange_acronym)

    if securities_list.nil? || !securities_list.is_a?(Array) || securities_list.empty?
      puts "Error: Failed to fetch securities list or no securities found"
      next
    end

    total_count = securities_list.size
    puts "Found #{total_count} securities to import"

    success_count = 0
    failed_tickers = []

    securities_list.each_with_index do |security_data, index|
      ticker = security_data["ticker"]
      puts "[#{index + 1}/#{total_count}] Importing #{ticker}..."

      begin
        security = importer.import_security(ticker, exchange_mic)

        if security
          puts "  Success: Imported #{ticker} - #{security.name}"
          success_count += 1

          # Also fetch the latest price for this security
          price = importer.import_security_price(security)
          if price
            puts "    Added current price: #{price.price} #{security.default_currency.code}"
          else
            puts "    Warning: Could not fetch current price"
          end
        else
          puts "  Failed: Could not import #{ticker}"
          failed_tickers << ticker
        end
      rescue => e
        puts "  Error importing #{ticker}: #{e.message}"
        failed_tickers << ticker
      end

      # Add a small delay to avoid rate limiting
      sleep(0.5) unless index == total_count - 1
    end

    puts "\nImport completed:"
    puts "Successfully imported: #{success_count} securities"

    if failed_tickers.any?
      puts "Failed to import: #{failed_tickers.size} securities"
      puts "Failed tickers: #{failed_tickers.join(', ')}"
    end
  end

  desc "Import all securities from a specific exchange"
  task :import_exchange_securities, [ :exchange_acronym ] => :environment do |t, args|
    exchange_acronym = args[:exchange_acronym]

    if exchange_acronym.blank?
      puts "Error: Exchange acronym cannot be blank. Usage: rake synth_finance:import_exchange_securities[NYSE]"
      next
    end

    Rake::Task["synth_finance:import_argentina_securities"].invoke if exchange_acronym.upcase == "BCBA"

    # For other exchanges, implement similar functionality as the Argentina task
    # or extend the Argentina task to be more generic
    unless exchange_mic.upcase == "BCBA"
      puts "Import for exchange #{exchange_acronym} is not implemented yet"
    end
  end
end


  desc "Import a security from Synth Finance API"
  task :import_security, [ :ticker, :exchange_mic ] => :environment do |t, args|
    ticker = args[:ticker]
    exchange_mic = args[:exchange_mic]

    if ticker.blank?
      puts "Error: Ticker cannot be blank. Usage: rake synth_finance:import_security[AAPL,XNAS]"
      next
    end

    importer = SynthFinance::SecurityImporter.new
    security = importer.import_security(ticker, exchange_mic)

    if security
      puts "Successfully imported security: #{security.ticker} - #{security.name}"
    else
      puts "Failed to import security: #{ticker}"
    end
  end

  desc "Update prices for all securities"
  task update_all_prices: :environment do
    importer = SynthFinance::SecurityImporter.new

    Security.find_each do |security|
      puts "Updating prices for #{security.ticker}..."
      price = importer.import_security_price(security)

      if price
        puts "  Success: Price updated to #{price.price} #{security.default_currency.code}"
      else
        puts "  Failed to update price for #{security.ticker}"
      end
    end
  end
