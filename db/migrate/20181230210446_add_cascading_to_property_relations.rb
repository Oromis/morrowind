class AddCascadingToPropertyRelations < ActiveRecord::Migration
  def change
    remove_foreign_key :property_modifiers, :properties
    add_foreign_key :property_modifiers, :properties, on_delete: :cascade
    remove_foreign_key :property_modifiers, :character_properties
    add_foreign_key :property_modifiers, :character_properties, on_delete: :cascade
  end
end
