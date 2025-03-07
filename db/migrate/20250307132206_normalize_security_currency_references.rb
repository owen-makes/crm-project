# db/migrate/[timestamp]_normalize_security_currency_references.rb
class NormalizeSecurityCurrencyReferences < ActiveRecord::Migration[7.2]
  def change
    # Add security reference to holdings
    add_column :holdings, :security_id, :uuid
    add_foreign_key :holdings, :securities
    remove_columns :holdings, :ticker, :asset_type

    # Add currency reference to security_prices
    add_reference :security_prices, :currency, foreign_key: { to_table: :currencies }
    remove_column :security_prices, :currency

    # Update exchange_rates structure
    change_table :exchange_rates do |t|
      t.references :base_currency, foreign_key: { to_table: :currencies }
      t.references :target_currency, foreign_key: { to_table: :currencies }
      t.index [ :date, :base_currency_id, :target_currency_id ], unique: true
      t.remove :source
    end
  end
end
