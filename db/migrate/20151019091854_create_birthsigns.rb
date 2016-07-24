class CreateBirthsigns < ActiveRecord::Migration
  def change
    create_table :birthsigns do |t|
      t.string :name
      t.attachment :image
      t.text :abilities
      t.references :rule_set, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
