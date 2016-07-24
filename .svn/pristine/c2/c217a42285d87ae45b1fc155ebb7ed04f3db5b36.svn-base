require 'test_helper'

class RuleSetTest < ActiveSupport::TestCase
  def setup
    @one = rule_sets(:one)
    @one_one = rule_sets(:one_one)
    @two = rule_sets(:two)
  end

  test "latest not nil without items" do
    RuleSet.delete_all
    assert_not_nil RuleSet.latest
  end

  test "latest works and considers deactivated items" do
    assert_equal @one_one, RuleSet.latest
  end

  test "items_by_type" do
    all = @two.item_prototypes
    assert_equal 4, all.length, "Please update this test case!"

    items = @two.items_by_type
    assert items.is_a?(Array)
    assert_equal 2, items.length    # melee & ranged weapons
    assert_equal 2, items[0].length # 1H & 2H swords
    assert_equal 1, items[1].length # Bows
    assert_equal 2, items[0][0].length  # Long & Broadsword
    assert_equal 1, items[0][1].length  # Claymore
    assert_equal 1, items[1][0].length  # Bow

    assert items[0][0][0].melee_weapon?
    assert_equal "1H-Schwerter", items[0][0][0].category
    assert items[0][0][1].melee_weapon?
    assert_equal "1H-Schwerter", items[0][0][1].category
    assert_equal items[0][0][0].slot, items[0][0][1].slot
    assert items[0][0][0].name < items[0][0][1].name

    assert items[0][1][0].melee_weapon?
    assert_equal "2H-Schwerter", items[0][1][0].category

    assert items[1][0][0].ranged_weapon?
    assert_equal "Bögen", items[1][0][0].category
  end

  test "init formulas" do
    assert_not_empty @two.formulas
    assert_equal "Start TP", @two.formula_by_abbr('start_health').name
  end
end
