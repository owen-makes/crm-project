class AddTeamIdToLeads < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :team_id, :integer
  end
end
