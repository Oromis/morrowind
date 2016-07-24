class AddArrowDmgToRangedWeapons < ActiveRecord::Migration
  def change
    add_column :items, :arrow_dmg, :integer, default: 0
  end
end
