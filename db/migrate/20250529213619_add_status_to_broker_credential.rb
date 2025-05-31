class AddStatusToBrokerCredential < ActiveRecord::Migration[7.2]
  def change
    add_column :broker_credentials, :status, :integer, null: false, default: 0
    add_index  :broker_credentials, :status
  end
end
