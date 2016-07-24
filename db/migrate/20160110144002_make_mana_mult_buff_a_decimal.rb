class MakeManaMultBuffADecimal < ActiveRecord::Migration
  def change
    change_column :characters, :mana_mult_buff, :decimal
  end
end
