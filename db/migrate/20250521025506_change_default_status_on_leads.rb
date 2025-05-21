class ChangeDefaultStatusOnLeads < ActiveRecord::Migration[7.2]
  def change
    change_column_default :leads, :status, from: nil, to: 0   # 0 == :nuevo
    change_column_null    :leads, :status, false
  end
end
