class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.string :type
      t.datetime :date
      t.integer :quantity
      t.float :price
      t.float :fees
      t.references :currency, null: false, foreign_key: true
      t.references :portfolio, null: false, foreign_key: true
      t.references :security, null: false, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
