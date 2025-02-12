class Team < ApplicationRecord
  belongs_to :admin, class_name: "User"
  has_many :members, class_name: "User", foreign_key: "team_id"
  validates :name, :admin_id, presence: true
  has_many :leads
  has_many :clients
  has_many :csv_imports
  before_create :generate_join_token
  after_create :add_admin_as_member

  private

  def add_admin_as_member
    admin.update!(team: self) unless admin.team == self
  end

  def generate_join_token
    self.join_token ||= SecureRandom.urlsafe_base64(10)
  end
end
