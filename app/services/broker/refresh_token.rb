module Broker
  class RefreshToken
    Result = Struct.new(:success?, :error, keyword_init: true)

    def self.call(credential) = new(credential).call

    # ------------------------------------------------------------------
    def initialize(credential)
      @credential = credential
    end

    # Public ­– main entry
    # ------------------------------------------------------------------
    def call
      case @credential.provider.to_sym
      when :iol then refresh_iol
      else            Result.new(success?: false,
                                 error:     "Proveedor no soportado")
      end
    end

    private

    # ---- provider-specific helpers -----------------------------------
    def refresh_iol
      client = Iol::Base.new(refresh_token: @credential.refresh_token,
                            username: @credential.username,
                            password: @credential.password
      )
      new_access = client.refresh_token     # may raise AuthError / NetworkError

      @credential.update!(
        access_token:     new_access,
        refresh_token:    client.refresh_token,  # IOL often rotates it
        token_expires_at: client.token_expires_at || Time.current + 15.minutes,
        last_authenticated_at: Time.current,
        status:           :ok
      )

      schedule_next_refresh
      Result.new(success?: true)
    rescue StandardError => e
      @credential.update(status: :error, last_error: e.message)
      Result.new(success?: false, error: e.message)
    end

    # ---- scheduling --------------------------------------------------
    def schedule_next_refresh
      return unless @credential.token_expires_at
      run_at = @credential.token_expires_at - 5.minutes
      run_at = 30.seconds.from_now if run_at < Time.current # don’t schedule in the past

      Rails.logger.info "🔄 scheduling next refresh for #{@credential.id} at #{run_at}"

      RefreshBrokerTokenJob.set(wait_until: run_at)
                          .perform_later(@credential.id)
    end
  end
end
