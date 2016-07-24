class AddArmorFieldsToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :armor_buff, :decimal, default: 0
  end
end
