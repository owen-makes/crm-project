class RenameCiphertextColumnsOnBrokerCredentials < ActiveRecord::Migration[7.2]
  def change
    rename_column :broker_credentials, :username_ciphertext, :username
    rename_column :broker_credentials, :password_ciphertext, :password
  end
end
