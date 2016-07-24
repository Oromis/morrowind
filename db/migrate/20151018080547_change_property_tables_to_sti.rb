class ChangePropertyTablesToSti < ActiveRecord::Migration
  def up
    drop_table :skills
    drop_table :attributes

    create_table :properties do |t|
      # Common fields
      t.string :type
      
      t.string :name, null: false
      t.string :abbr, null: false, index: true
      t.integer :order, default: 0
      t.attachment :icon
      t.references :rule_set, index: true, foreign_key: true
      
      # Stuff for attributes
      t.integer :default_value, default: 40

      # Stuff for skills
      t.references :attribute
      t.references :specialization, foreign_key: true

      t.timestamps null: false
    end
    add_foreign_key :properties, :properties, column: 'attribute_id', primary_key: 'id'
  end

  def down 
    raise ActiveRecord::IrreversibleMigration, "Can't restore dropped tables!"
  end
end
