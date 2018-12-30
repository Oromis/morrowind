class AddCascadingToPropertyRelations < ActiveRecord::Migration
  def change
    remove_foreign_key :property_modifiers, :properties
    add_foreign_key :property_modifiers, :properties, on_delete: :cascade
    remove_foreign_key :character_properties, :properties
    add_foreign_key :character_properties, :properties, on_delete: :cascade
  end
end
