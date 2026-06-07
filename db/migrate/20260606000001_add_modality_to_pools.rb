class AddModalityToPools < ActiveRecord::Migration[8.1]
  def change
    add_column :pools, :modality, :string, null: false, default: "stages"
    add_column :pools, :stages, :text
    add_reference :pools, :focus_match, null: true, foreign_key: { to_table: :matches }
  end
end
