class DeleteInvitation < ActiveRecord::Migration[7.2]
  def up
    drop_table :invitations
  end

  def down
    create_table :invitations do |t|
      t.string :email
      t.string :token
      t.bigint :team_id, null: false
      t.bigint :sender_id, null: false
      t.string :status
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :sender_id, name: "index_invitations_on_sender_id"
      t.index :team_id, name: "index_invitations_on_team_id"
    end

    add_foreign_key :invitations, :teams
    add_foreign_key :invitations, :users, column: :sender_id
  end
end
