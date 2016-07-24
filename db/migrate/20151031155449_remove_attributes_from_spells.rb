class RemoveAttributesFromSpells < ActiveRecord::Migration
  def change
    remove_foreign_key :spells, column: :attribute1_id
    remove_foreign_key :spells, column: :attribute2_id

    remove_column :spells, :attribute1_id
    remove_column :spells, :attribute2_id
  end
end
