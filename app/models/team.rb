class Team < ApplicationRecord
  belongs_to :admin, class_name: "User"
  has_many :members, class_name: "User", foreign_key: "team_id"
  has_many :invitations
  validates :name, :admin_id, presence: true
  after_create :add_admin_as_member

  private

  def add_admin_as_member
    admin.update!(team: self) unless admin.team == self
  end
end
