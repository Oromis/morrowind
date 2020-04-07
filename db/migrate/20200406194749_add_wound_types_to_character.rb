class AddWoundTypesToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :wounds_head, :integer, default: 0
    add_column :characters, :wounds_arm, :integer, default: 0
    add_column :characters, :wounds_torso, :integer, default: 0
    add_column :characters, :wounds_belly, :integer, default: 0
    add_column :characters, :wounds_leg, :integer, default: 0
  end
end
