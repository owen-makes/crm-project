class Lead < ApplicationRecord
  belongs_to :user
  before_create :set_status
  validates :name, :last_name, :email, :phone, presence: true

  private

  def set_status
    self.status = "Cold"
  end
end
