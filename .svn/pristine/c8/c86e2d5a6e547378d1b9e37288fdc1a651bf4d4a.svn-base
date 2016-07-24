class AddAttackAndParryValuesToCharacterSkill < ActiveRecord::Migration
  def change
    add_column :character_properties, :attack, :decimal, default: 0
    add_column :character_properties, :parry, :decimal, default: 0

    add_column :characters, :offensive_buff, :integer, default: 0
    add_column :characters, :defensive_buff, :integer, default: 0
  end
end
