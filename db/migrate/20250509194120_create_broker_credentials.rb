class CreateBrokerCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :broker_credentials do |t|
      t.integer :provider, null: false, default: 0
      t.text :access_token_ciphertext
      t.text :refresh_token_ciphertext
      t.datetime :token_expires_at
      t.string :account_number
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end

    # One credential per team
    add_index :broker_credentials, %i[team_id provider], unique: true
    add_index :broker_credentials, :token_expires_at
  end
end
