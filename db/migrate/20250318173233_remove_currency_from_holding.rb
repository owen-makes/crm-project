class RemoveCurrencyFromHolding < ActiveRecord::Migration[7.2]
  def change
    remove_reference :holdings, :currency, null: false, foreign_key: true
  end
end
