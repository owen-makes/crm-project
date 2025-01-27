class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.string :name
      t.references :admin, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
