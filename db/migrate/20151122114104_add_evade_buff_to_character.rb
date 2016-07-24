class AddEvadeBuffToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :evasion_buff, :integer, default: 0
  end
end
