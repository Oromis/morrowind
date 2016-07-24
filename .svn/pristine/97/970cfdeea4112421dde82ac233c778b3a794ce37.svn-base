class CreateSpecializations < ActiveRecord::Migration
  def change
    create_table :specializations do |t|
      t.string :name
      t.references :rule_set, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
