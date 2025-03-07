
class AddCurrencyConsistency < ActiveRecord::Migration[7.2]
  def change
    # Add currency to holdings and portfolios
    add_reference :holdings, :currency, foreign_key: true
    add_reference :portfolios, :currency, foreign_key: true

    # Update leads capital to decimal
    change_column :leads, :capital, :decimal, precision: 19, scale: 4
  end
end
