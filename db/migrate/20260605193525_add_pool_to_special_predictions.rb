class AddPoolToSpecialPredictions < ActiveRecord::Migration[8.1]
  def change
    SpecialPrediction.delete_all if table_exists?(:special_predictions)
    add_reference :special_predictions, :pool, null: false, foreign_key: true
    remove_index :special_predictions, column: [:player_id, :tournament_id] if index_exists?(:special_predictions, [:player_id, :tournament_id])
    remove_reference :special_predictions, :tournament
    add_index :special_predictions, [:player_id, :pool_id], unique: true
  end
end
