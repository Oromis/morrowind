class AddCombatSkillsReferencesToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :attack_prop_1_id, :integer
    add_column :properties, :attack_prop_2_id, :integer
    add_column :properties, :attack_prop_3_id, :integer

    add_column :properties, :parry_prop_1_id, :integer
    add_column :properties, :parry_prop_2_id, :integer
    add_column :properties, :parry_prop_3_id, :integer

    add_foreign_key :properties, :properties, column: :attack_prop_1_id, on_delete: :nullify
    add_foreign_key :properties, :properties, column: :attack_prop_2_id, on_delete: :nullify
    add_foreign_key :properties, :properties, column: :attack_prop_3_id, on_delete: :nullify

    add_foreign_key :properties, :properties, column: :parry_prop_1_id, on_delete: :nullify
    add_foreign_key :properties, :properties, column: :parry_prop_2_id, on_delete: :nullify
    add_foreign_key :properties, :properties, column: :parry_prop_3_id, on_delete: :nullify
  end
end
