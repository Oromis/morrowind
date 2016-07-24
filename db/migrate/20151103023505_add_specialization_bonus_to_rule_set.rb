class AddSpecializationBonusToRuleSet < ActiveRecord::Migration
  def change
    add_column :rule_sets, :specialization_bonus, :integer, default: 5
  end
end
