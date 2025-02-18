class CreateHoldings < ActiveRecord::Migration[7.2]
  def change
    create_table :holdings do |t|
      t.string :ticker
      t.string :asset_type
      t.integer :quantity
      t.integer :cost_basis
      t.references :portfolio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
