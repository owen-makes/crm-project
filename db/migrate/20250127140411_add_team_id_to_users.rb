class AddTeamIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :team_id, :integer
  end
end
