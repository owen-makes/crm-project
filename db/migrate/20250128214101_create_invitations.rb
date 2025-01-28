class CreateInvitations < ActiveRecord::Migration[7.2]
  def change
    create_table :invitations do |t|
      t.string :email
      t.string :token
      t.references :team, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.string :status

      t.timestamps
    end
  end
end
