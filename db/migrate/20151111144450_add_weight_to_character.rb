class AddWeightToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :backpack_weight, :decimal, default: 0
    add_column :characters, :body_weight, :decimal, default: 0
  end
end
