class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :player, null: false, foreign_key: true
      t.references :pool, null: false, foreign_key: true
      t.timestamps
    end
    add_index :memberships, [:player_id, :pool_id], unique: true
  end
end
