class AddClumsinessToItem < ActiveRecord::Migration
  def change
    add_column :items, :clumsiness, :decimal, default: 0
    add_column :item_prototypes, :clumsiness, :decimal, default: 0
  end
end
