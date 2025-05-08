module IOL
  class Titulos < Base
    ALLOWED_COUNTRIES = [ "Argentina", "Estados_Unidos" ].freeze
    ALLOWED_MARKETS = [ "BCBA", "NYSE", "NASDAQ", "AMEX", "BCS", "ROFX" ].freeze
    FUND_TYPE = [
      "plazo_fijo_pesos",
      "plazo_fijo_dolares",
      "renta_fija_pesos",
      "renta_fija_dolares",
      "renta_mixta_pesos",
      "renta_mixta_dolares",
      "renta_variable_pesos",
      "renta_variable_dolares"
    ].freeze
    SETTLEMENTS = [ "T1", "CI" ].freeze
    ADJUSTED = [ "ajustada", "sinAjustar" ].freeze

    # Fetch + symbol + information
    # (simbolo, descripcion/nombre, pais, mercado, tipo/instrumento, plazo, moneda)
    def get_market_security(symbol, market: "BCBA")
      market = validate_market!(market)
      get("/api/v2/#{market}/Titulos/#{symbol}")
    end
    # Fetch securities by + country + (only Estados_Unidos y Argentina)
    # Devuelve Instrumento y Pais nomas CREO, no entiendo bien
    def get_all_country_securities(country: "Argentina")
      country = validate_country!(country)
      get("/api/v2/#{country}/Titulos/Cotizacion/Instrumentos")
    end

    # Fetch +symbol+ information (only Estados_Unidos y Argentina)
    # Igual que el anterior, no es muy claro que devuelve
    def get_country_security(symbol, country: "Argentina")
      country = validate_country!(country)
      get("/api/v2/#{country}/Titulos/Cotizacion/Instrumentos/#{symbol}")
    end

    # Symbol here refers to option
    # simboloSubyacente, fechaVencimiento, tipoOpcion, simbolo, descripcion...
    def get_market_option_contract(symbol, market: "BCBA")
      market = validate_market!(market)
      get("/api/v2/#{market}/Titulos/#{symbol}/Opciones")
    end

    # Get historical prices
    # Date format: yyyy-mm-dd
    # Adjusted: "ajustada" or "sinAjustar"
    def get_historical_prices(symbol, date_from, date_to, adjusted, market: "BCBA")
      market = validate_market!(market)
      raise ArgumentError, "Invalid argument for adjusted: #{adjusted.inspect}" unless ADJUSTED.include?(adjusted)

      get("/api/v2/#{market}/Titulos/#{symbol}/Cotizacion/seriehistorica/#{date_from}/#{date_to}/#{adjusted}")
    end

    # Returns ultimoPrecio, variacion, apertura, max, min, fechaHora, tendencia, montoOperado, volumenNominal...
    def get_last_price(symbol, market: "BCBA", settlement: "T1")
      settlement = validate_settlement!(settlement)
      get("/api/v2/#{market}/Titulos/#{symbol}/Cotizacion?plazo=#{settlement}")
    end

    # Same as get_last_price but also returns:
    # cantidadOperaciones, pais, mercado, tipo, descripcionTitulo, plazo, laminaMinima, lote...
    def get_security_details(symbol, market: "BCBA")
      market = validate_market!(market)
      get("/api/v2/#{market}/Titulos/#{symbol}/CotizacionDetalle")
    end

    # -------------- FCIs / Mutual Funds -------------------
    # Returns all fund types from an administrator (administradora, identificadorTipoFondoFCI, nombreTipoFondoFCI)
    def get_issuer_fcis(issuer)
      get("/api/v2/Titulos/FCI/Administradoras/#{issuer}/TipoFondos")
    end

    # Return list with detail of administrator according to fund type
    # horizonteInversion, invierte (detalles), descripcion, rescate...
    def get_issuer_fcis_by_type(issuer, fund_type)
      fund_type = validate_fund_type!(fund_type)

      get("/api/v2/Titulos/FCI/Administradoras/#{issuer}/TipoFondos/#{fund_type}")
    end

    def get_issuers
      get("/api/v2/Titulos/FCI/Administradoras")
    end

    def get_all_fci
      get("/api/v2/Titulos/FCI")
    end

    def get_fci(symbol) # ej: PRCPPEB
      get("/api/v2/Titulos/FCI/#{symbol}")
    end

    def get_fund_types
      get("/api/v2/Titulos/FCI/TipoFondos")
    end

    private

    def validate_market!(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid market #{value.inspect}" unless ALLOWED_MARKETS.include?(value)
      value
    end

    def validate_country!(value)
      value = value.to_s
      raise ArgumentError, "Invalid country #{value.inspect}" unless ALLOWED_COUNTRIES.include?(value)
      value
    end

    def validate_settlement!(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid settlement #{value.inspect}" unless SETTLEMENTS.include?(value)
      value
    end

    def validate_fund_type!(value)
      raise ArgumentError, "Invalid fund type #{value.inspect}" unless FUND_TYPES.include?(value)
      value
    end
  end
end
