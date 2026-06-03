class AddEmailToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :email, :string
    add_column :players, :email_verified_at, :datetime
    add_index :players, :email, unique: true
  end
end
