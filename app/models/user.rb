class User < ApplicationRecord
  has_many :clients
  has_many :leads
  has_many :csv_imports
  has_one :managed_team, foreign_key: "admin_id", class_name: "Team"
  belongs_to :team, optional: true
  has_one :profile, dependent: :destroy
  after_create :create_profile
  enum :role, [ :member, :admin ]
  before_create :generate_form_token, :set_role
  devise :invitable, :database_authenticatable, :registerable,
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

  def remove_from_team(reassign_to:)
    # Start a transaction to ensure data consistency
    User.transaction do
      # Reassign clients to the specified user
      clients.update_all(user_id: reassign_to.id) if clients.any?
      # Reassign leads to the specified user
      leads.update_all(user_id: reassign_to.id) if leads.any?
      # Remove user from team
      update!(team_id: nil, role: nil)
    end
  end

  private

  def create_profile
    build_profile.save
  end

  def generate_form_token
    self.form_token ||= SecureRandom.hex(4)
  end

  def set_role
    self.role = self.team_id.nil? ? "admin" : "member"
  end
end
