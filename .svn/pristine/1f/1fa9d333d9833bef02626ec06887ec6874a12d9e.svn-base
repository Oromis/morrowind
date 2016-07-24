require 'test_helper'

class BirthsignTest < ActiveSupport::TestCase
  def setup
    @birthsign = birthsigns(:warrior)
    @attribute = properties(:str)
    @skill = properties(:axe)
  end

  test "default valid" do
    assert @birthsign.valid?
  end

  test "name required" do
    @birthsign.name = ' '
    assert_not @birthsign.valid?
  end

  test "rule set required" do
    @birthsign.rule_set = nil
    assert_not @birthsign.valid?
  end

  test "add property modifiers" do
    count = @birthsign.property_modifiers.count
    op = '+'
    val = -20
    mod = @birthsign.property_modifiers.new(property: @skill, 
                                      operator: op,
                                      value: val)
    assert @birthsign.valid?
    @birthsign.save!
    mod_id = mod.id
    assert_not_nil mod_id

    @birthsign.reload
    assert_equal count + 1, @birthsign.property_modifiers.count
    mod = @birthsign.property_modifiers.find(mod_id)
    assert_equal @skill, mod.property
    assert_equal op, mod.operator
    assert_equal val, mod.value
  end

  test "property modifier polymorphism" do
    @birthsign.property_modifiers.destroy_all
    @birthsign.property_modifiers.new(property: @attribute, 
                                      operator: '+',
                                      value: 10)
    @birthsign.property_modifiers.new(property: @skill,
                                      operator: '-',
                                      value: 20)
    @birthsign.save!

    sign = Birthsign.find(@birthsign.id)
    assert @birthsign == sign
    assert_equal 2, @birthsign.property_modifiers.count
    a = @birthsign.property_modifiers.find_by(property_id: @attribute.id)
    assert_kind_of Attribute, a.property
    assert_equal '+', a.operator
    assert_equal 10, a.value

    b = @birthsign.property_modifiers.find_by(property_id: @skill.id)
    assert_kind_of Skill, b.property
    assert_equal '-', b.operator
    assert_equal 20, b.value
  end

  test "validation of property modifiers is delegated" do
    mod = @birthsign.property_modifiers.new(property: @skill,
                                            operator: '',
                                            value: 20)
    assert_not @birthsign.valid?
    mod.operator = '+'
    mod.value = 'Peter'
    assert_not @birthsign.valid?
    mod.value = 10
    mod.property = nil
    assert_not @birthsign.valid?
    assert_not @birthsign.save
    mod.property = @skill
    assert @birthsign.valid?
  end
end
