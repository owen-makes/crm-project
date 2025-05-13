class AddLoginToBrokerCredentials < ActiveRecord::Migration[7.2]
  def change
    add_column :broker_credentials, :username_ciphertext, :text
    add_column :broker_credentials, :password_ciphertext, :text
  end
end
