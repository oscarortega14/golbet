class AddPoolToPredictions < ActiveRecord::Migration[8.1]
  def change
    Prediction.delete_all if table_exists?(:predictions)
    add_reference :predictions, :pool, null: false, foreign_key: true
    remove_index :predictions, column: [:player_id, :match_id] if index_exists?(:predictions, [:player_id, :match_id])
    add_index :predictions, [:player_id, :pool_id, :match_id], unique: true
  end
end
