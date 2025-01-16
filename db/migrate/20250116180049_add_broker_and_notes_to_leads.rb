class AddBrokerAndNotesToLeads < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :broker, :string
    add_column :leads, :notes, :text
  end
end
