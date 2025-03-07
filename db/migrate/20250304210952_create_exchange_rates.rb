class CreateExchangeRates < ActiveRecord::Migration[7.2]
  def change
    create_table :exchange_rates do |t|
      t.decimal :rate, precision: 19, scale: 4
      t.datetime :date
      t.string :source

      t.timestamps
    end
  end
end
