class AddFormTokenToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :form_token, :string
    add_index :users, :form_token, unique: true
  end
end
