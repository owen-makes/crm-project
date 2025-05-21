class StatusStringToEnumOnLeads < ActiveRecord::Migration[7.2]
  # If your table is big, you can drop this line and let the whole thing
  # run inside one transaction.  Keeping it speeds up bulk UPDATEs on PG.
  disable_ddl_transaction!

  MAP = {
    'nuevo'      => 0,
    'wip'        => 1,
    'cerrado'    => 2,
    'convertido' => 2,   # legacy label
    'baja'       => 3
  }.freeze

  # --------------------
  # Upgrade
  # --------------------
  def up
    # 1. Add a temporary integer column
    add_column :leads, :status_tmp, :integer

    # 2. Copy data over
    MAP.each do |label, code|
      execute <<~SQL.squish
        UPDATE leads
           SET status_tmp = #{code}
         WHERE LOWER(status) = '#{label}'
      SQL
    end

    # Any rows with unknown / NULL strings fall back to :nuevo (0)
    execute <<~SQL.squish
      UPDATE leads
         SET status_tmp = 0
       WHERE status_tmp IS NULL
    SQL

    # 3. Swap the columns
    remove_column :leads, :status
    rename_column :leads, :status_tmp, :status

    # 4. Add NOT-NULL and default (optional but common)
    change_column_default :leads, :status, from: nil, to: 0
    change_column_null    :leads, :status, false
  end

  # --------------------
  # Rollback
  # --------------------
  def down
    add_column :leads, :status_str, :string

    execute <<~SQL.squish
      UPDATE leads
         SET status_str = CASE status
           WHEN 0 THEN 'Nuevo'
           WHEN 1 THEN 'WIP'
           WHEN 2 THEN 'Cerrado'
           WHEN 3 THEN 'Baja'
         END
    SQL

    remove_column :leads, :status
    rename_column :leads, :status_str, :status
  end
end
