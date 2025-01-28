class User < ApplicationRecord
  has_many :clients
  has_many :leads
  has_one :managed_team, foreign_key: "admin_id", class_name: "Team"
  belongs_to :team, optional: true
  enum role: [ :member, :admin ]
  before_create :generate_form_token
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, :last_name, :email, presence: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.first_name
      user.last_name = auth.info.last_name
    end
  end

  private

  def generate_form_token
    self.form_token ||= SecureRandom.hex(4)
  end
end
