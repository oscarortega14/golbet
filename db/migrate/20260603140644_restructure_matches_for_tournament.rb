class RestructureMatchesForTournament < ActiveRecord::Migration[8.1]
  def change
    if table_exists?(:matches)
      Prediction.delete_all if table_exists?(:predictions) # clear dependents first (pre-launch demo data)
      Match.delete_all # pre-launch demo data, safe to drop
    end

    add_column :matches, :stage, :string, null: false, default: "group"
    add_column :matches, :group, :string
    add_reference :matches, :home_team, foreign_key: { to_table: :teams }
    add_reference :matches, :away_team, foreign_key: { to_table: :teams }
    add_column :matches, :home_label, :string
    add_column :matches, :away_label, :string
    add_column :matches, :slot, :integer
    remove_column :matches, :home_team, :string # old string column
    remove_column :matches, :away_team, :string # old string column
  end
end
