class CreateSpecialPredictions < ActiveRecord::Migration[8.1]
  def change
    create_table :special_predictions do |t|
      t.references :player, null: false, foreign_key: true
      t.references :tournament, null: false, foreign_key: true
      t.references :champion_team, null: true, foreign_key: { to_table: :teams }
      t.string :top_scorer
      t.timestamps
    end
    add_index :special_predictions, [:player_id, :tournament_id], unique: true
  end
end
