class AddEmojiToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :emoji, :string
  end
end
