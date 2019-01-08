class AddColorToProperty < ActiveRecord::Migration
  def change
    add_column :properties, :color, :string, limit: 1000
  end
end
