class AddJoinTokenToTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :teams, :join_token, :string
  end
end
