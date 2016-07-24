require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  def setup 
    @ability = abilities(:thunderfist)
  end

  test "default valid" do
    assert @ability.valid?
  end

  test "name required" do
    @ability.name = ' '
    assert_not @ability.valid?
  end
end
