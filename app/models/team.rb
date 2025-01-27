class Team < ApplicationRecord
  belongs_to :admin, class_name: "User"
  has_many :members, class_name: "User", foreign_key: "team_id"
  validates :name, :admin_id, presence: :true
end
