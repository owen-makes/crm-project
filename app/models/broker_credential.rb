class BrokerCredential < ApplicationRecord
  belongs_to :team

  enum provider: { iol: 0 }, _prefix: true

  encrypts :access_token, deterministic: false
  encrypts :refresh_token, deterministic: false

  validates  :provider, presence: true
  validates  :team_id,  uniqueness: { scope: :provider } # one key per team
end
