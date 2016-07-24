class AllowNullForItemName < ActiveRecord::Migration
  def change
    change_column :items, :name, :string, null: true
  end
end
