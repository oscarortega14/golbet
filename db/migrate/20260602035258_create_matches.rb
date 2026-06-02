class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :home_team
      t.string :away_team
      t.datetime :kickoff_at
      t.integer :home_score
      t.integer :away_score
      t.string :status

      t.timestamps
    end
  end
end
