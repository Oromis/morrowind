class AddConditionToItem < ActiveRecord::Migration
  def change
    add_column :items, :condition, :integer, default: 100
  end
end
