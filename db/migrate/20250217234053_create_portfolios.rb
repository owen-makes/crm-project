class CreatePortfolios < ActiveRecord::Migration[7.2]
  def change
    create_table :portfolios do |t|
      t.string :broker
      t.integer :account_number
      t.string :name
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
