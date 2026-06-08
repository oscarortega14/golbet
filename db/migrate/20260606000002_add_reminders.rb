class AddReminders < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :email_reminders, :boolean, null: false, default: true

    create_table :match_reminders do |t|
      t.references :player, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true
      t.datetime :sent_at, null: false
      t.timestamps
    end
    add_index :match_reminders, [:player_id, :match_id], unique: true
  end
end
