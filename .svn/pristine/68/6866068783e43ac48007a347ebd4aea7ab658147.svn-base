class CreateResistances < ActiveRecord::Migration
  def change
    create_table :resistances do |t|
      t.string :name, null: false
      t.string :abbr, null: false, index: true
      t.integer :order, default: 0
      t.attachment :icon
      t.references :rule_set, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
