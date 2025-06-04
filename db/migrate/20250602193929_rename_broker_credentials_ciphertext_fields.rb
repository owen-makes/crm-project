class RenameBrokerCredentialsCiphertextFields < ActiveRecord::Migration[7.2]
  def change
    rename_column :broker_credentials, :access_token_ciphertext, :access_token
    rename_column :broker_credentials, :refresh_token_ciphertext, :refresh_token
  end
end
