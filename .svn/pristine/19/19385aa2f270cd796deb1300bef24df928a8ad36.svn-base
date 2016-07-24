class ChangeCharacterProperty < ActiveRecord::Migration
  def up
    change_column :character_properties, :points_base, :float
    add_column :character_properties, :skill_type, :integer, default: 0
  end

  def down
    change_column :character_properties, :points_base, :integer
    remove_column :character_properties, :skill_type
  end
end
