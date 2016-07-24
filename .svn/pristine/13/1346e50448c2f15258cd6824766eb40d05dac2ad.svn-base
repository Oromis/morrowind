require 'test_helper'

class SkillTest < ActiveSupport::TestCase
  def setup
    @skill = properties(:axe)
    @rule_set = rule_sets(:one)
  end

  test "default valid" do
    assert @skill.valid?
  end

  test "attr required" do
    @skill.attr = nil
    assert_not @skill.valid?
  end

  test "specialization required" do
    @skill.specialization = nil
    assert_not @skill.valid?
  end
end
