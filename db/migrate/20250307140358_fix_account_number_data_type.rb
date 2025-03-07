class FixAccountNumberDataType < ActiveRecord::Migration[7.2]
  def change
    change_column :portfolios, :account_number, :string
  end
end
