class CreatePools < ActiveRecord::Migration[8.1]
  def change
    create_table :pools do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :owner, foreign_key: { to_table: :players }, null: true
      t.string :name, null: false
      t.string :invite_token, null: false
      t.boolean :public, null: false, default: false
      t.timestamps
    end
    add_index :pools, :invite_token, unique: true
  end
end
