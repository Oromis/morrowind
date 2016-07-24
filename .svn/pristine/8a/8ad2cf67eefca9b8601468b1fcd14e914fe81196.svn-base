class CreateSpells < ActiveRecord::Migration
  def change
    create_table :spells do |t|
      t.string :name
      t.string :desc
      t.integer :mana_cost
      t.decimal :min_effect
      t.decimal :max_effect
      t.integer :duration
      t.integer :range

      t.references :rule_set, foreign_key: true
      t.references :attribute1  # Check 1
      t.references :attribute2  # Check 2
      t.references :school      # Check 3

      t.attachment :image

      t.timestamps null: false
    end

    add_foreign_key :spells, :properties, column: :attribute1_id, on_delete: :nullify
    add_foreign_key :spells, :properties, column: :attribute2_id, on_delete: :nullify
    add_foreign_key :spells, :properties, column: :school_id, on_delete: :nullify
  end
end
