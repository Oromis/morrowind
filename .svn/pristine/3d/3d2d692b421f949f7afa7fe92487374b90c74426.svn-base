class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.string :name
      t.string :key
      t.references :character, index: true, foreign_key: true, null: false
      t.references :item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
