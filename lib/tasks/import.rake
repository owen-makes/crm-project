# lib/tasks/import.rake
namespace :import do
  desc "Import all securities and currencies"
  task securities_and_currencies: :environment do
    puts "Starting securities and currencies import..."
    importer = MarketData::SecuritiesImportService.new
    importer.import_securities
    puts "Import completed!"
  end

  desc "Import and update latest prices for all securities"
  task update_prices: :environment do
    puts "Updating latest prices for all securities..."
    price_service = MarketData::PriceService.new
    securities = Security.all
    price_service.update_latest_prices(securities)
    puts "Price update completed!"
  end
end
