class FixTeamIdDataType < ActiveRecord::Migration[7.2]
  def change
    change_column :clients, :team_id, :bigint
  end
end
