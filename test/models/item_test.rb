require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def setup
    @item = items(:claymore)
    @dep = items(:broadsword)
    @proto = @dep.prototype
  end

  test 'weight calculation' do
    @item.quantity = 1
    weight = @item.weight

    assert_equal weight, @item.total_weight

    @item.quantity = 3
    assert_equal weight * 3, @item.total_weight
  end

  test 'save empty propagated attribute' do
    @dep.name = nil
    @dep.save!
    @dep.reload
    assert_nil @dep[:name]
    assert_equal @proto.name, @dep.name
  end

  test 'save filled propagated attribute' do
    @dep.name = 'Hans'
    @dep.save!
    @dep.reload
    assert_equal 'Hans', @dep[:name]
    assert_equal 'Hans', @dep.name
  end

  test 'item should not save a value that is identical on the prototype' do
    @dep.name = @proto.name
    assert_equal @proto.name, @dep[:name]
    @dep.save!
    @dep.reload
    assert_nil @dep[:name]
    assert_equal @proto.name, @dep.name
  end

  test 'prototype change reflected in item' do
    @dep.name = nil
    assert_equal @proto.name, @dep.name
    @proto.name = 'Testitus'
    assert_equal @proto.name, @dep.name
  end

  test 'min_damage' do
    @item.damage = '30'
    assert_equal 30, @item.min_damage
    @item.damage = '4+3d6'
    assert_equal 4, @item.min_damage
    @item.damage = ' 2 + 4w6 '
    assert_equal 2, @item.min_damage
    @item.damage = '4d6'
    assert_equal 0, @item.min_damage
    @item.damage = 'hans'
    assert_equal 0, @item.min_damage
  end

  test 'set prototype to nil on prototype destruction' do
    @proto.destroy
    @dep.reload
    assert_nil @dep.prototype
    assert_nil @dep.prototype_id
  end

  test 'name propagation' do
    propagation_test :name, 'Other'
  end
  test 'weight propagation' do
    propagation_test :weight, 999
  end
  test 'value propagation' do
    propagation_test :value, 1
  end
  test 'range propagation' do
    propagation_test :range, 20
  end
  test 'speed propagation' do
    propagation_test :speed, 2
  end
  test 'damage propagation' do
    propagation_test :damage, '2+10w6'
  end
  test 'armor propagation' do
    propagation_test :armor, 90
  end
  test 'slot propagation' do
    propagation_test :slot, 'neck'
  end
  test 'type propagation' do
    propagation_test :type, 'accessory'
  end
  test 'clumsiness propagation' do
    propagation_test :clumsiness, 1.5
  end

  def propagation_test(prop, test_value)
    assert_not_equal @dep.prototype[prop], test_value, 'Setup error: Identical test values!'

    @dep.send("#{prop}=", nil)
    assert_equal @proto.send(prop), @dep.send(prop)
    @dep.send("#{prop}=", test_value)
    assert_equal test_value, @dep.send(prop)
    @dep.prototype = nil
    assert_equal test_value, @dep.send(prop)
    @dep.send("#{prop}=", nil)
    assert_nil @dep.send(prop)
  end
end