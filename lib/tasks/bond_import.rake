namespace :data912 do
  desc "Add security types to bonds from data912 open API"
  task import_bonds: :environment do
    api = Data912::ApiService.new
    ars = Currency.find_by(code: "ars")
    usd = Currency.find_by(code: "usd")
    exchange = Exchange.find_by(mic_code: "XBUE")
    arg_bonds = api.live_arg_bonds
    arg_notes = api.live_arg_notes
    arg_corp = api.live_arg_corp

    def mep_or_ccl(bond)
      bond["symbol"].ends_with?("c") ? "ccl" : "mep"
    end


    success = []
    arg_bonds.each do |bond|
      ticker = bond["symbol"]
      security = Security.find_by(ticker: ticker)
      currency = bond["c"] > 5000 ? ars : usd
      currency_type = mep_or_ccl(bond)

      unless security
        security = Security.create(
          ticker: ticker,
          name: ticker,
          security_type: :bond,
          currency_id: currency&.id,
          exchange_id: exchange&.id,
          details: { issuer_type: "government" }
        )
        security.update(details: security.details.merge(exchange_rate_type: currency_type)) if currency == usd
        puts "Created security #{security.ticker}"
        success << security.ticker
      end
    end

    arg_notes.each do |bond|
      ticker = bond["symbol"]
      security = Security.find_by(ticker: ticker)
      currency = bond["c"] > 5000 ? ars : usd
      currency_type = mep_or_ccl(bond)
      unless security
        security = Security.create(
          ticker: ticker,
          name: ticker,
          security_type: :bond,
          currency_id: currency&.id,
          exchange_id: exchange&.id,
          details: { issuer_type: "government" }
        )
        security.update(details: security.details.merge(exchange_rate_type: currency_type)) if currency == usd
        puts "Created security #{security.ticker}"
        success << security.ticker
      end
    end

    arg_corp.each do |bond|
      ticker = bond["symbol"]
      security = Security.find_by(ticker: ticker)
      currency = bond["c"] > 5000 ? ars : usd
      currency_type = mep_or_ccl(bond)
      unless security
        security = Security.create(
          ticker: ticker,
          name: ticker,
          security_type: :bond,
          currency_id: currency&.id,
          exchange_id: exchange&.id,
          details: { issuer_type: "corporate" }
        )
        security.update(details: security.details.merge(exchange_rate_type: currency_type)) if currency == usd

        puts "Created security #{security.ticker}"
        success << security.ticker
      end
    end



    puts "Succesfully added #{success.count} bonds to database"
    p success
  end
end
