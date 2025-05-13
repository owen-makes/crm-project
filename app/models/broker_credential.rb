class BrokerCredential < ApplicationRecord
  belongs_to :team
  encrypts :access_token, :refresh_token, :username, :password

  enum provider: { iol: 0 }, _prefix: true

  with_options if: :iol? do
    validates :username_ciphertext, :password_ciphertext, presence: true
  end

  validates  :provider, presence: true
  validates  :team_id,  uniqueness: { scope: :provider } # one key per team

  def token_expired?
    token_expires_at && token_expires_at < Time.current
  end
end
