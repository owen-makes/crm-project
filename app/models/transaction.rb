class Transaction < ApplicationRecord
  # Polymorphic to support various transaction sources
  belongs_to :transactable, polymorphic: true
  belongs_to :portfolio
  belongs_to :security, optional: true
  belongs_to :currency

  # Enum for transaction types
  enum transaction_type: {
    dividend: 0,
    interest: 1,
    capital_gain: 2,
    deposit: 3,
    withdrawal: 4,
    buy: 5,
    sell: 6,
    fee: 7,
    transfer: 8
  }

  # Scopes for easy querying
  scope :income, -> { where(transaction_type: [ :dividend, :interest, :capital_gain ]) }
  scope :cash_movements, -> { where(transaction_type: [ :deposit, :withdrawal, :transfer ]) }
end
