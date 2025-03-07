class ChangeFloatTypes < ActiveRecord::Migration[7.2]
  def change
    # Update holdings table
    change_column :holdings, :quantity, :decimal, precision: 18, scale: 8
    change_column :holdings, :cost_basis, :decimal, precision: 19, scale: 4

    # Update transactions table
    change_column :transactions, :quantity, :decimal, precision: 18, scale: 8
    change_column :transactions, :price, :decimal, precision: 19, scale: 4
    change_column :transactions, :fees, :decimal, precision: 19, scale: 4
  end
end
