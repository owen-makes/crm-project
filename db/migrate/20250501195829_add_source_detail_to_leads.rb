class AddSourceDetailToLeads < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :source_detail, :string
  end
end
