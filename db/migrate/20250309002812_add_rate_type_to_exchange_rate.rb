class AddRateTypeToExchangeRate < ActiveRecord::Migration[7.2]
  def change
    add_column :exchange_rates, :rate_type, :string
  end
end
