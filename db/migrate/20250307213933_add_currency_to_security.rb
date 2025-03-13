class AddCurrencyToSecurity < ActiveRecord::Migration[7.2]
  def change
    add_reference :securities, :currency, null: false, foreign_key: true
  end
end
