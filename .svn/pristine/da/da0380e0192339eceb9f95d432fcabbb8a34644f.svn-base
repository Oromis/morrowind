class AddRawValuesToRuleSet < ActiveRecord::Migration
  def change
    add_column :rule_sets, :fav_attr_bonus, :integer, default: 10

    add_column :rule_sets, :minor_skill_count, :integer, default: 5
    add_column :rule_sets, :minor_skill_base, :integer, default: 15
    add_column :rule_sets, :major_skill_count, :integer, default: 5
    add_column :rule_sets, :major_skill_base, :integer, default: 30
    add_column :rule_sets, :other_skill_base, :integer, default: 5

    add_column :character_properties, :points_buff, :integer, default: 0
  end
end
