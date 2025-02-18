class Portfolio < ApplicationRecord
  belongs_to :client
  has_many :holdings
end
