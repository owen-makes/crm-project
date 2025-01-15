class Lead < ApplicationRecord
  belongs_to :user

  validates :name, :last_name, :email, :phone, presence: true
end
