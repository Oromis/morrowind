class CreateItemPrototypes < ActiveRecord::Migration
  def change
    create_table :item_prototypes do |t|
      t.string :name, null: false
      t.integer :type, default: 0
      t.string :category
      t.string :desc
      t.integer :value
      t.decimal :weight
      t.attachment :image

      # Weapons
      t.decimal :range
      t.string :damage
      t.decimal :speed
      t.boolean :two_handed

      # Armor
      t.integer :armor

      # All wearables
      t.integer :slot, default: nil

      t.timestamps null: false
    end
  end
end
