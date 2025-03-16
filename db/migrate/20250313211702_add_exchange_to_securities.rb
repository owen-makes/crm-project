class AddExchangeToSecurities < ActiveRecord::Migration[7.2]
  def change
    add_reference :securities, :exchange, null: false, foreign_key: true
    remove_column :securities, :country_code
    remove_column :securities, :exchange_mic
    remove_column :securities, :exchange_acronym
  end
end
