class AddCampaignToLeads < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :campaign, :string
  end
end
