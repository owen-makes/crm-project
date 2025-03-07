class CreateSecurities < ActiveRecord::Migration[7.2]
  def change
    create_table :securities, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :ticker
      t.string :name
      t.string :country_code
      t.string :exchange_mic
      t.string :exchange_acronym
      t.string :logo_url

      t.timestamps
    end

    add_index :securities, [ :ticker, :exchange_mic ], unique: true
    add_index :securities, :country_code
  end
end
