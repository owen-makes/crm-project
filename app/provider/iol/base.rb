# app/providers/iol/base.rb
module IOL
    class Base
      include HTTParty
      base_uri Rails.application.credentials.dig(:iol, :base_url) # => e.g. https://api.invertironline.com

      TOKEN_PATH = "/token".freeze

      def initialize(username:, password:)
        @username = username
        @password = password
      end

      # ––––– public helpers –––––
      def get(path, **opts)
        with_token  { self.class.get(path, headers: default_headers, **opts) }
      end

      def post(path, body: nil, **opts)
        with_token  { self.class.post(path, body:, headers: default_headers, **opts) }
      end

      # ––––– token handling –––––
      def token
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
        raise(Errors::Auth, response.parsed_response) unless response.success?

        payload            = response.parsed_response
        @token             = payload["access_token"]
        @token_expired_at  = Time.current + payload["expires_in"].to_i.seconds
        @token
      end

      private

      def default_headers
        { "Authorization" => "Bearer #{token}" }
      end

      def with_token
        token # → refresh on demand
        yield
      rescue HTTParty::Error, SocketError => e
        raise Errors::Network, e
      end

      def token_expired?
        @token_expired_at && Time.current >= @token_expired_at
      end
    end
end
