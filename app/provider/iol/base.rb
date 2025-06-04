# app/providers/iol/base.rb
module Iol
    class Base
      class Error < StandardError; end
      class AuthError < Error; end
      class NetworkError < Error; end
      include HTTParty
      base_url = Rails.application.credentials.dig(:iol, :base_url) ||
      ENV["IOL_BASE_URL"] ||
      "https://api.invertironline.com"
      attr_reader :refresh_token, :token_expires_at

      base_uri base_url

      TOKEN_PATH = "/token".freeze

      def initialize(username: nil, password: nil, refresh_token: nil)
        @username = username
        @password = password
        @refresh_token = refresh_token
      end

      # ––––– public helpers –––––
      def get(path, **opts)
        with_token  { self.class.get(path, headers: default_headers, **opts) }
      end

      def post(path, body: nil, **opts)
        with_token  { self.class.post(path, body:, headers: default_headers, **opts) }
      end

      def iso_date(date)
        (date.is_a?(Date) || date.is_a?(Time)) ? date.iso8601 : date.to_s
      end

      # ––––– token handling –––––

      def token
        return @token if @token && !token_expired?

        @refresh_token.present? ? refresh_access_token! : password_grant_token
      end

      def password_grant_token
        return @token if @token && !token_expired?

        response = self.class.post(
          TOKEN_PATH,
          headers: { "Content-Type" => "application/x-www-form-urlencoded" },
          body: {
            grant_type: "password",
            username:   @username,
            password:   @password
          }
        )
        raise AuthError, response.parsed_response unless response.success?

        payload = response.parsed_response
        @token = payload["access_token"]
        @refresh_token = payload["refresh_token"]
        @token_expires_at  = Time.current + payload["expires_in"].to_i.seconds
        @token
      end

      def refresh_access_token!
        response = self.class.post(
          TOKEN_PATH,
          headers: { "Content-Type" => "application/x-www-form-urlencoded" },
          body: {
            grant_type:    "refresh_token",
            refresh_token: @refresh_token
          }
        )
        raise AuthError, response.parsed_response unless response.success?

        payload = response.parsed_response
        @token = payload["access_token"]
        @token_expires_at = Time.current + payload["expires_in"].to_i.seconds
        @refresh_token = payload["refresh_token"]

        @token
      end

      def get_account_data
        get("/api/v2/datos-perfil")
      end


      private

      def default_headers
        { "Authorization" => "Bearer #{token}" }
      end

      def with_token
        token # → refresh on demand
        yield
      rescue HTTParty::Error, SocketError => e
        raise NetworkError, e
      end

      def token_expired?
        @token_expires_at && Time.current >= @token_expires_at
      end
    end
end
