# lib/tasks/synth_finance.rake
namespace :synth_finance do
  desc "Import all securities from the Argentine stock market (BYMA/BCBA)"
  task import_argentina_securities: :environment do
    importer = SynthFinance::SecurityImporter.new
    mic = "XBUE"

    importer.import_exchange_and_securities(mic)

    puts "\nImport completed: #{Security.all.count} securities"
  end

  desc "Import all currencies"
  task import_currencies: :environment do
    importer = SynthFinance::SecurityImporter.new

    importer.import_currencies

    puts "\nImport completed: #{Currency.all.count} securities"
  end

  desc "Import all exchanges"
  task import_exchanges: :environment do
    importer = SynthFinance::SecurityImporter.new

    importer.import_exchanges

    puts "\nImport completed: #{Exchange.all.count} securities"
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


  # desc "Import a security from Synth Finance API"
  # task :import_security, [ :ticker, :exchange_mic ] => :environment do |t, args|
  #   ticker = args[:ticker]
  #   exchange_mic = args[:exchange_mic]

  #   if ticker.blank?
  #     puts "Error: Ticker cannot be blank. Usage: rake synth_finance:import_security[AAPL,XNAS]"
  #     next
  #   end

  #   importer = SynthFinance::SecurityImporter.new
  #   security = importer.import_security(ticker, exchange_mic)

  #   if security
  #     puts "Successfully imported security: #{security.ticker} - #{security.name}"
  #   else
  #     puts "Failed to import security: #{ticker}"
  #   end
  # end

  # desc "Update prices for all securities"
  # task update_all_prices: :environment do
  #   importer = SynthFinance::SecurityImporter.new

  #   Security.find_each do |security|
  #     puts "Updating prices for #{security.ticker}..."
  #     price = importer.import_security_price(security)

  #     if price
  #       puts "  Success: Price updated to #{price.price} #{security.default_currency.code}"
  #     else
  #       puts "  Failed to update price for #{security.ticker}"
  #     end
  #   end
  # end

  desc "Get securities logos"
  task get_logos: :environment do
    securities = Security.all

    securities.each do |sec|
      sec.update(logo_url: "https://logo.synthfinance.com/ticker/#{sec.ticker}")
    end
  end
end
