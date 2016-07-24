require 'test_helper'

class AttributeTest < ActiveSupport::TestCase
  def setup
    @attr = properties(:str)
    @rule_set = rule_sets(:one)
  end

  test "default valid" do
    assert @attr.valid?
  end

  test "attribute name valid" do
    @attr.name = ' '
    assert_not @attr.valid?

    a = @rule_set.attrs.new(abbr: 'abc')
    a.name = @attr.name
    assert_not a.valid?
  end

  test "attribute abbr valid" do
    @attr.abbr = ' '
    assert_not @attr.valid?

    a = @rule_set.attrs.new(name: 'abc')
    a.abbr = @attr.abbr
    assert_not a.valid?
  end

  test "rule_set mandatory" do
    @attr.rule_set = nil
    assert_not @attr.valid?
  end

  test "default valid numerical" do
    @attr.default_value = 'hans'
    assert_not @attr.valid?

    @attr.default_value = 1.2
    assert_not @attr.valid?

    @attr.default_value = -1
    assert_not @attr.valid?

    @attr.default_value = 101
    assert_not @attr.valid?

    @attr.default_value = 0
    assert @attr.valid?

    @attr.default_value = 100
    assert @attr.valid?

    @attr.default_value = 20
    assert @attr.valid?
  end
end
