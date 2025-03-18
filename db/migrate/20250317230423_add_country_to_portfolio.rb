class AddCountryToPortfolio < ActiveRecord::Migration[7.2]
  def change
    add_column :portfolios, :country, :string
  end
end
