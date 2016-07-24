class CreateCharacterProperties < ActiveRecord::Migration
  def change
    create_table :character_properties do |t|
      t.column :type, :string
      t.column :points_base, :integer
      t.column :points_gained, :integer, default: 0
      t.column :order, :integer, default: 0
      t.column :multiplier, :integer, default: 0

      t.references :property, foreign_key: true, index: true
      t.references :character, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
