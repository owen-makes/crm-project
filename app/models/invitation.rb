class Invitation < ApplicationRecord
  belongs_to :team
  belongs_to :sender, class_name: "User" # references admin

  before_create :generate_token

  validates :email, presence: true, uniqueness: { scope: :team_id }

  def generate_token
    self.token = SecureRandom.hex(16)
  end
end
