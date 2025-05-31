class AddAuthTrackingToBrokerCredentials < ActiveRecord::Migration[7.2]
  def change
    add_column :broker_credentials, :last_authenticated_at, :datetime
    add_column :broker_credentials, :last_error, :text
  end
end
