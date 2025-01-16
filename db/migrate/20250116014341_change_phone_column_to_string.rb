class ChangePhoneColumnToString < ActiveRecord::Migration[7.2]
  def change
    change_column :leads, :phone, :string
  end
end
