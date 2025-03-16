class CreateExchanges < ActiveRecord::Migration[7.2]
  def change
    create_table :exchanges do |t|
      t.string :name
      t.string :country_code
      t.string :acronym
      t.string :mic_code
      t.string :city

      t.timestamps
    end
  end
end
