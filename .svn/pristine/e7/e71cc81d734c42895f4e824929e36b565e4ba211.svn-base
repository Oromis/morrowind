class AddRuleSetToRace < ActiveRecord::Migration
  def change
    add_reference :races, :rule_set, index: true, foreign_key: true
  end
end
