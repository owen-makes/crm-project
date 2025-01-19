class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :last_name
      t.string :phone
      t.string :channel
      t.string :broker
      t.string :email
      t.text :notes
      t.text :goals
      t.references :user, null: false, foreign_key: true


      t.timestamps
    end
  end
end
