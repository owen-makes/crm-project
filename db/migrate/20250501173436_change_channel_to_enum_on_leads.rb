class ChangeChannelToEnumOnLeads < ActiveRecord::Migration[7.2]
  def up
    # 1. Get rid of the old string column (any existing values are discarded)
    remove_column :leads, :channel

    # 2. Re-create it as an integer, ready for enum
    add_column :leads, :channel, :integer, null: false, default: 0
    add_index  :leads, :channel
  end

  def down
    # Exact reversal: drop the int and bring back the string
    remove_column :leads, :channel
    add_column    :leads, :channel, :string
  end
end
