class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.string :name
      t.string :session_token

      t.timestamps
    end
    add_index :players, :session_token, unique: true
  end
end
