class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :name, null: false
      t.string :code, null: false
      t.string :flag
      t.string :group, null: false
      t.timestamps
    end
    add_index :teams, [:tournament_id, :code], unique: true
  end
end
