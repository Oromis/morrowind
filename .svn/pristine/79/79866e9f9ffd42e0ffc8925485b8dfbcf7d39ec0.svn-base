class CreatePropertyModifiers < ActiveRecord::Migration
  def change
    create_table :property_modifiers do |t|
      t.integer :owner_id
      t.string :owner_type
      t.references :property, foreign_key: true, index: true
      t.string :operator
      t.decimal :value

      t.timestamps null: false
    end
  end
end
