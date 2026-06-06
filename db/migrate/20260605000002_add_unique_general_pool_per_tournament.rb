class AddUniqueGeneralPoolPerTournament < ActiveRecord::Migration[8.1]
  def change
    remove_index :pools, name: "index_pools_on_single_public", if_exists: true
    add_index :pools, :tournament_id, unique: true, where: "public = 1",
              name: "index_pools_on_general_per_tournament"
  end
end
