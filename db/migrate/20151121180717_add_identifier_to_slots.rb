class AddIdentifierToSlots < ActiveRecord::Migration
  def change
    add_column :slots, :identifier, :string
  end
end
