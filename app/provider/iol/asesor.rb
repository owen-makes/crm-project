module IOL
  class Asesor < Base
    # --------------------- Constants & helpers ---------------------
    ALLOWED_COUNTRIES = %w[Argentina Estados_Unidos].freeze
    ALLOWED_STATUSES  = %w[Pendientes Liquidadas Canceladas Anuladas].freeze

    def iso_date(date)
      (date.is_a?(Date) || date.is_a?(Time)) ? date.iso8601 : date.to_s
    end
    private :iso_date
    # ---------- Bank acct transfers/deposits/withdrawals/MOVIMIENTOS ---------------
    # Returns client transactions (from_date, to_date, idTipo, idEstado, tipoCuenta)
    def get_client_transfers(client_id,
                            from_date: nil,
                            to_date: nil,
                            id_tipo: nil,
                            id_estado: nil,
                            tipo_cuenta: nil)
      body = {
        FechaDesde: iso_date(from_date),
        FechaHasta: iso_date(to_date),
        IdTipo:     id_tipo,
        IdEstado:   id_estado,
        TipoCuenta: tipo_cuenta
      }.compact

      # Docs specify POST with JSON body
      post("/api/v2/Asesor/Movimiento/Historico/#{client_id}", body)
    end

    # Returns all clients transactions
    # Docs not clear on how to use variables, assuming it's params
    def get_all_clients_transfers(from_date, to_date)
      post("/api/v2/Asesor/Movimientos?from=#{from_date}&to=#{to_date}")
    end
  end

  # ----------- Securities transactions --------------
  # Returns??
  def get_client_transactions(client_id:,
                              status:        "Pendientes",
                              country:       "Argentina",
                              transaction_number: nil,
                              from_date:,
                              to_date:)
    raise ArgumentError, "Invalid country: #{country}" unless ALLOWED_COUNTRIES.include?(country)
    raise ArgumentError, "Invalid status: #{status}"   unless ALLOWED_STATUSES.include?(status)

    query = {
    IdClienteAsesorado: client_id,
    Estado:             status,
    Pais:               country,
    Numero:             transaction_number,
    FechaDesde:         iso_date(from_date),
    FechaHasta:         iso_date(to_date)
    }.compact

    get("/api/v2/Asesores/Operaciones?#{URI.encode_www_form(query)}")
  end

  def get_transaction_details(client_id, transaction_number)
    get("/api/v2/Asesores/Operaciones/Detalle/#{client_id}/#{transaction_number}")
  end

  def get_boleto(client_id, transaction_number)
    get("/api/v2/Asesores/Operaciones/Boleto/#{client_id}/#{transaction_number}")
  end

  # ----------- Account / Portfolio -------------
  def get_client_account(client_id)
    get("/api/v2/Asesores/EstadoDeCuenta/#{client_id}")
  end

  def get_client_portoflio(client_id, country: "Argentina")
    get("/api/v2/Asesores/Portafolio/#{client_id}/#{country}")
  end
end
