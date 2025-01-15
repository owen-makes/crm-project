class AddUserIdToLeads < ActiveRecord::Migration[7.2]
  def change
    add_reference :leads, :user, null: false, foreign_key: true
  end
end
