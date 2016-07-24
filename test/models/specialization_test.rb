require 'test_helper'

class SpecializationTest < ActiveSupport::TestCase
  def setup
    @spec = specializations(:mage)
  end

  test "rule_set mandatory" do
    assert @spec.valid?

    @spec.rule_set = nil
    assert_not @spec.valid?
  end

  test "name mandatory" do
    assert @spec.valid?

    @spec.name = ''
    assert_not @spec.valid?
  end
end
