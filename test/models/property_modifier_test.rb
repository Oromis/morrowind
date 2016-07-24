require 'test_helper'

class PropertyModifierTest < ActiveSupport::TestCase
  def setup 
    @owner = races(:dunmer)
    @prop = properties(:str)
    @mod = PropertyModifier.new(owner: @owner,
                                property: @prop,
                                operator: '+',
                                value: 10)
  end

  test "default valid" do
    assert @mod.valid?
  end

  test "property mandatory" do
    @mod.property = nil
    assert_not @mod.valid?
  end

  test "operator valid" do
    ['', nil, ' ', 'hans', '#', '20', 20].each do |val|
      @mod.operator = val
      assert_not @mod.valid?, "#{val} should not be valid!"
    end
    ['+', '-', '*', '/'].each do |val|
      @mod.operator = val
      assert @mod.valid?, "#{val} should be valid!"
    end
  end

  test "value valid" do
    @mod.value = 0
    assert @mod.valid?
    @mod.value = 0.5
    assert @mod.valid?
    @mod.value = -20
    assert @mod.valid?
    @mod.value = 30
    assert @mod.valid?

    @mod.value = 'Test'
    assert_not @mod.valid?
    @mod.value = ' '
    assert_not @mod.valid?
    @mod.value = nil
    assert_not @mod.valid?
  end

  test "modify_value" do
    @mod.operator = '+'
    @mod.value = 10
    assert_equal 25, @mod.modify_value(15)

    @mod.operator = '-'
    assert_equal 35, @mod.modify_value(45)

    @mod.value = -10
    assert_equal 20, @mod.modify_value(10)

    @mod.operator = '*'
    @mod.value = 2
    assert_equal 40, @mod.modify_value(20)

    @mod.operator = '/'
    assert_equal 10, @mod.modify_value(20)
  end

  test "modify" do
    cp = CharacterAttribute.new(property: @prop)
    cp.init(Character.new)
    assert_equal @prop.default_value + 10, @mod.modify(cp)
  end
end
