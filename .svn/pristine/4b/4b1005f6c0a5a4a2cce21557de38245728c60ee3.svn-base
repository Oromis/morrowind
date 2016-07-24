class AddSchoolOfMagicToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :school_of_magic, :boolean, default: false
    add_column :properties, :check1_id, :integer
    add_column :properties, :check2_id, :integer

    add_foreign_key :properties, :properties, column: :check1_id, on_delete: :nullify
    add_foreign_key :properties, :properties, column: :check2_id, on_delete: :nullify
  end
end
