class ChangeArmorColumnToDecimal < ActiveRecord::Migration
  def change
    change_column :item_prototypes, :armor, :decimal
    change_column :items, :armor, :decimal
  end
end
