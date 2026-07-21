class AddSinglePublicPoolIndex < ActiveRecord::Migration[8.1]
  def change
    add_index :pools, :public, unique: true, where: "public = true", name: "index_pools_on_single_public"
  end
end
