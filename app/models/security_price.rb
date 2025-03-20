class SecurityPrice < ApplicationRecord
  belongs_to :security

  validates :date, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :security_id, uniqueness: { scope: :date }
end
