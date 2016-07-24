class AddLocationAndTimeToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :location, :string, default: ''
    add_column :characters, :day, :integer, default: 1
    add_column :characters, :month, :string, default: :morgenstern
  end
end
