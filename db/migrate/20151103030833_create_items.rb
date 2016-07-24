class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :type, default: 0
      t.string :desc
      t.integer :quantity
      t.integer :value
      t.decimal :weight
      t.integer :index, default: nil
      t.integer :container, default: 0

      t.decimal :range
      t.string :damage
      t.decimal :speed

      t.integer :armor
      t.integer :slot, default: nil

      t.references :prototype
      t.references :character, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
