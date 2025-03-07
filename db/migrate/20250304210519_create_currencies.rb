class CreateCurrencies < ActiveRecord::Migration[7.2]
  def change
    create_table :currencies do |t|
      t.string :code
      t.string :name
      t.string :symbol
      t.string :country

      t.timestamps
    end
  end
end
