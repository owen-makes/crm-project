class AddEmailToLead < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :email, :string
  end
end
