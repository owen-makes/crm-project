class SecurityPrice < ApplicationRecord
  belongs_to :security
  belongs_to :currency
end
