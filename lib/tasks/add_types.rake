namespace :data912 do
  desc "Add security types to stocks from data912 open API"
  task add_types_to_stocks: :environment do
    api = Data912::ApiService.new

    arg_stocks = api.live_arg_stocks
    success = []
    arg_stocks.each do |stock|
      ticker = stock["symbol"]
      security = Security.find_by(ticker: ticker)
      if security
        security.update(security_type: :stock)
        puts "Updated type for Security #{security.ticker}"
        success << security.ticker
      end
    end

    puts "Succesfully updated type for #{success.count} stocks"
    p success
  end

  desc "Add security types to cedears from data912 open API"
  task add_types_to_cedears: :environment do
    api = Data912::ApiService.new

    arg_stocks = api.live_arg_cedears
    success = []
    arg_stocks.each do |stock|
      ticker = stock["symbol"]
      security = Security.find_by(ticker: ticker)
      if security
        security.update(security_type: :cedear)
        puts "Updated type for Security #{security.ticker}"
        success << security.ticker
      end
    end

    puts "Succesfully updated type for #{success.count} stocks"
    p success
  end

  desc "Add security types to bonds from data912 open API"
  task add_types_to_bonds: :environment do
    api = Data912::ApiService.new

    arg_bonds = api.live_arg_bonds
    arg_notes = api.live_arg_notes
    arg_corp = api.live_arg_corp

    success = []
    arg_bonds.each do |bond|
      ticker = bond["symbol"]
      security = Security.find_by(ticker: ticker)
      if security
        security.update(security_type: :bond, details: { issuer_type: "government" })
        puts "Updated type for Security #{security.ticker}"
        success << security.ticker
      end
    end

    arg_notes.each do |bond|
      ticker = bond["symbol"]
      security = Security.find_by(ticker: ticker)
      if security
        security.update(security_type: :bond, details: { issuer_type: "government" })
        puts "Updated type for Security #{security.ticker}"
        success << security.ticker
      end
    end

    arg_corp.each do |bond|
      ticker = bond["symbol"]
      security = Security.find_by(ticker: ticker)
      if security
        security.update(security_type: :bond, details: { issuer_type: "corporate" })
        puts "Updated type for Security #{security.ticker}"
        success << security.ticker
      end
    end

    puts "Succesfully updated type for #{success.count} stocks"
    p success
  end
end
