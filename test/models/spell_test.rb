require 'test_helper'

class SpellTest < ActiveSupport::TestCase
  def setup 
    @spell = spells(:firebite) 
  end

  test "default valid" do
    assert @spell.valid?
  end

  test "name required" do
    @spell.name = ' '
    assert_not @spell.valid?
  end

  test "rule_set required" do
    @spell.rule_set = nil
    assert_not @spell.valid?
  end

  test "manacost numeric" do
    @spell.mana_cost = nil
    assert_not @spell.valid?
    @spell.mana_cost = 'hans'
    assert_not @spell.valid?
  end

  test "duration valid" do
    @spell.duration = 'hans'
    assert_not @spell.valid?
    @spell.duration = 1.1
    assert_not @spell.valid?
    @spell.duration = nil
    assert @spell.valid?
    @spell.duration = -1
    assert_not @spell.valid?
    @spell.duration = 10
    assert @spell.valid?
  end

  test "range in foot" do
    @spell.range = :melee
    assert_equal '5 ft', @spell.range_in_ft
    @spell.range = :support
    assert_equal '15 ft', @spell.range_in_ft
    @spell.range = :attack
    assert_equal '20 ft', @spell.range_in_ft
  end

  test "school required" do
    @spell.school = nil
    assert_not @spell.valid?
  end
end
