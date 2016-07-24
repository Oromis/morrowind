class AddActivatedToRuleSet < ActiveRecord::Migration
  def change
    add_column :rule_sets, :activated, :boolean
  end
end
