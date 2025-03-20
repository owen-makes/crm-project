namespace :comafi do
  desc "Get cedears conversion ratio, country, industry and add type to etfs"
  task add_cedear_data: :environment do
    require "csv"

    file_path = Rails.root.join("lib", "assets", "cedears.csv")

    CSV.foreach(file_path, headers: true) do |row|
      ticker = row["Identificaci\u00F3n Mercado"]&.strip
      security = Security.find_by(ticker: ticker)
      next unless security

      # Extract details
      country = row["Pa\u00EDs de Origen"]&.strip
      industry = row["Industria"]&.strip
      sub_industry = row["Descripci\u00F3n de la Industria"]&.strip
      ratio = row["Ratio Cedear/Acci\u00F3n \u00F3 ADR"]&.strip

      # Parse conversion ratio
      conversion_ratio = ratio&.match(/(\d+):(\d+)/)
      conversion_ratio = conversion_ratio ? conversion_ratio[1].to_i.fdiv(conversion_ratio[2].to_i) : nil

      # Update details
      security.details ||= {}
      security.details.merge!(
        "country" => country,
        "industry" => industry,
        "sub_industry" => sub_industry,
        "conversion_ratio" => conversion_ratio
      )

      # Determine security type
      if industry&.downcase == "etf"
        security.security_type = :etf
      else
        security.security_type = :cedear
      end

      security.save!
    end
  end
end
