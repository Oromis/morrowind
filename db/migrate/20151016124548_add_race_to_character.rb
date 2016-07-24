class AddRaceToCharacter < ActiveRecord::Migration
  def change
    add_reference :characters, :race, index: true, foreign_key: true
  end
end
