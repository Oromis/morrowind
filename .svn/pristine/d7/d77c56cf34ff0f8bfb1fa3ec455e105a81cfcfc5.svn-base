class AddBirthsignEtcToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :status, :integer, default: 0
    add_reference :characters, :birthsign, foreign_key: true
    add_reference :characters, :specialization, foreign_key: true
    add_reference :characters, :fav_attribute1
    add_reference :characters, :fav_attribute2

    add_column :characters, :title, :string
    add_column :characters, :health, :integer, default: 0
    add_column :characters, :max_health, :integer, default: 0
    add_column :characters, :stamina, :integer, default: 0
    add_column :characters, :mana, :integer, default: 0

    change_column :characters, :level, :integer, default: 1
    change_column :characters, :level_count, :integer, default: 0

    add_foreign_key :characters, :properties, column: :fav_attribute1_id, on_delete: :nullify
    add_foreign_key :characters, :properties, column: :fav_attribute2_id, on_delete: :nullify
  end
end
