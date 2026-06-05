class AddActiveToTournaments < ActiveRecord::Migration[8.1]
  def up
    add_column :tournaments, :active, :boolean, null: false, default: false
    # El torneo existente (si lo hay) queda como activo.
    first = Tournament.order(:id).first
    first&.update_column(:active, true)
  end

  def down
    remove_column :tournaments, :active
  end
end
