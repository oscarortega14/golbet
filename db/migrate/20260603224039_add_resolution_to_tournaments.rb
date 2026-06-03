class AddResolutionToTournaments < ActiveRecord::Migration[8.1]
  def change
    add_reference :tournaments, :champion_team, foreign_key: { to_table: :teams }, null: true
    add_column :tournaments, :top_scorer, :string
  end
end
