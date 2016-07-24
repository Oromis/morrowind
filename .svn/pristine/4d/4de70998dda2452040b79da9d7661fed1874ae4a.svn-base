class AddWeaponSkillsToCharacterSkills < ActiveRecord::Migration
  def change
    add_column :properties, :weapon_skill, :boolean, default: false
    add_column :properties, :weapon_skill_mode, :integer, default: 0

    add_column :character_properties, :points_offensive, :integer, default: 0
    add_column :character_properties, :points_defensive, :integer, default: 0
  end
end
