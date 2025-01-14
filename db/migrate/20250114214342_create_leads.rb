class CreateLeads < ActiveRecord::Migration[7.2]
  def change
    create_table :leads do |t|
      t.string :name
      t.string :last_name
      t.integer :phone
      t.string :status
      t.string :channel
      t.integer :capital

      t.timestamps
    end
  end
end
