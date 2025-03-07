# db/migrate/[timestamp]_create_security_prices.rb
class CreateSecurityPrices < ActiveRecord::Migration[7.2]
  def change
    create_table :security_prices, id: :uuid do |t|
      t.references :security, null: false, type: :uuid, foreign_key: true
      t.date :date
      t.decimal :price, precision: 19, scale: 4
      t.string :currency

      t.timestamps
    end
  end
end
