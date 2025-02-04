class AddTeamIdToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :team_id, :integer
  end
end
