class AddRuleSetToItemPrototype < ActiveRecord::Migration
  def change
    add_reference :item_prototypes, :rule_set, index: true, foreign_key: true
  end
end
