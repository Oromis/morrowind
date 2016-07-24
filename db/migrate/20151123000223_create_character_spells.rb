class CreateCharacterSpells < ActiveRecord::Migration
  def change
    create_table :characters_spells do |t|
      t.belongs_to :character, index: true, foreign_key: true
      t.belongs_to :spell, index: true, foreign_key: true
    end
  end
end
