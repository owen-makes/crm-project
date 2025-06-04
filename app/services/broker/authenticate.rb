module Broker
  class Authenticate
    def self.call(credential)
      new(credential).call
    end

    def initialize(credential)
      @credential = credential
    end

    def call
      case @credential.provider.to_sym
      when :iol then authenticate_iol
      else           Result.failure("Proveedor no soportado")
      end
    end

    private

    Result = Struct.new(:success?, :error, keyword_init: true)

    def authenticate_iol
      client = Iol::Base.new(
        username: @credential.username,
        password: @credential.password
      )

      token = client.token # ← will raise on failure
      refresh_token = client.refresh_token

      @credential.update!(
        access_token:     token,
        refresh_token:    refresh_token,
        token_expires_at: client.token_expires_at || Time.current + 15.minutes,
        last_authenticated_at: Time.now
      )

      schedule_refresh
      Result.new(success?: true)
    rescue StandardError => e
      Result.new(success?: false, error: e.message)
    end

    def schedule_refresh
      RefreshBrokerTokenJob.set(
        wait_until: @credential.token_expires_at - 5.minutes
      ).perform_later(@credential.id)
    end
  end
end
