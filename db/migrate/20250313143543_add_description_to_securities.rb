class AddDescriptionToSecurities < ActiveRecord::Migration[7.2]
  def change
    add_column :securities, :description, :text
  end
end
