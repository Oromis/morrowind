class CreateAbilities < ActiveRecord::Migration
  def change
    create_table :abilities do |t|
      t.string :name
      t.string :desc

      t.integer :owner_id
      t.string :owner_type

      t.timestamps null: false
    end
  end
end
