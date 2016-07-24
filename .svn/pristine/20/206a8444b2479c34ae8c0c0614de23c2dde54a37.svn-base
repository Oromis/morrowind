require 'test_helper'

class ItemPrototypeTest < ActiveSupport::TestCase
  def setup
    @item = ItemPrototype.new(name: "Test", type: :generic, weight: 1)
  end

  test "name mandatory" do
    @item.name = ' '
    assert_not @item.valid?
    @item.name = "Test"
    assert @item.valid?
  end

  test 'weight > 0' do
    @item.weight = -0.2
    assert_not @item.valid?
    @item.weight = 0
    assert_not @item.valid?
    @item.weight = 0.1
    assert @item.valid?
  end

  test 'armor integer or decimal' do
    @item.armor = 1.5
    assert @item.valid?
    @item.armor = 2
    assert @item.valid?
  end

  test 'test type' do
    @item.type = nil
    assert_not @item.valid?
    assert_not @item.weapon?
    assert_not @item.wearable?

    @item.melee_weapon!
    assert @item.weapon?
    assert @item.wearable?

    @item.ranged_weapon!
    assert @item.weapon?
    assert @item.wearable?

    @item.armor!
    assert_not @item.weapon?
    assert @item.wearable?

    @item.consumable!
    assert_not @item.weapon?
    assert_not @item.wearable?

    @item.accessory!
    assert_not @item.weapon?
    assert @item.wearable?
  end
end
