class AddRulesToPools < ActiveRecord::Migration[8.1]
  def change
    add_column :pools, :exact_points, :integer, null: false, default: 3
    add_column :pools, :outcome_points, :integer, null: false, default: 1
    add_column :pools, :knockout_multipliers, :boolean, null: false, default: true
    add_column :pools, :special_enabled, :boolean, null: false, default: true
    add_column :pools, :champion_bonus, :integer, null: false, default: 15
    add_column :pools, :top_scorer_bonus, :integer, null: false, default: 10
  end
end
