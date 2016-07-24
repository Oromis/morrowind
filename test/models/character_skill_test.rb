require 'test_helper'

class CharacterSkillTest < ActiveSupport::TestCase
  def setup
    @char = characters(:nazir)
  end

  test "init" do
    @char.save!
    skill = @char.skills.first
    assert_not_nil skill

    skill.other!
    skill.init(@char)
    assert_equal 5, skill.points_base

    skill.minor!
    skill.init(@char)
    assert_equal 15, skill.points_base

    skill.major!
    skill.init(@char)
    assert_equal 30, skill.points_base

    @char.specialization = skill.property.specialization
    skill.init(@char)
    assert_equal 35, skill.points_base
  end

  test 'battle points distribution' do
    @char.save!
    skill = @char.skills.first
    skill.points_base = 44  # 8 Points
    skill.points_offensive = 5
    skill.points_defensive = 3
    assert_equal 5, skill.points_offensive
    assert_equal 3, skill.points_defensive

    skill.points_offensive = 10
    assert_equal 5, skill.points_offensive
    assert_equal 3, skill.points_defensive

    skill.points_defensive = 10
    assert_equal 4, skill.points_offensive
    assert_equal 4, skill.points_defensive

    skill.points_defensive = 1
    skill.points_offensive = 7
    assert_equal 6, skill.points_offensive
    assert_equal 2, skill.points_defensive
  end
end
