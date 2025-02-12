class CreateCsvImports < ActiveRecord::Migration[7.2]
  def change
    create_table :csv_imports do |t|
      t.string :file
      t.json :headers
      t.json :data
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
