class BrokerCredential < ApplicationRecord
  belongs_to :team
  encrypts :access_token, :refresh_token, :username, :password

  enum :provider, { iol: 0 }, prefix: true

  enum :status, {
    pending: 0,   # just saved / awaiting auth
    ok:      1,   # authenticated
    error:   2    # last auth attempt failed
  }, prefix: true

  with_options if: :provider_iol? do
    validates :username, :password, presence: true
  end

  validates  :provider, presence: true
  validates  :team_id,  uniqueness: { scope: :provider } # one key per team

  def token_expired?
    token_expires_at && token_expires_at < Time.current
  end

  def self.provider_display_name(provider_key)
    {
      "iol" => "InvertirOnline"
    }[provider_key] || provider_key.humanize
  end

  def provider_display_name
    self.class.provider_display_name(provider)
  end
end
