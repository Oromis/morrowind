require 'test_helper'

class SkillsControllerTest < ActionController::TestCase
  def setup
    @skill = properties(:axe)
    @gm = users(:arian)
    @rule_set = rule_sets(:one)
    log_in_as @gm
  end

  test "should get index" do
    get :index, rule_set_id: @rule_set
    assert_response :success
  end

  test "should get new" do
    get :new, rule_set_id: @rule_set
    assert_response :success
  end

  test "should get create" do
    assert_difference 'Skill.count', 1 do
      post :create, rule_set_id: @rule_set, skill: { name: 'xyz', abbr: 'y', 
                                                     rule_set_id: @rule_set.id,
                                                     attribute_id: @skill.attr.id,
                                                     specialization_id: @skill.specialization.id }
    end
    assert_redirected_to rule_set_skills_path(@rule_set)
  end

  test "should get edit" do
    get :edit, rule_set_id: @rule_set, id: @skill
    assert_response :success
  end

  test "should get update" do
    name = 'aklsjd'
    abbr = 'a'
    patch :update, rule_set_id: @rule_set, id: @skill, skill: { name: name, abbr: abbr }
    @skill.reload
    assert_redirected_to rule_set_skills_path(@rule_set)
    assert_equal name, @skill.name
    assert_equal abbr, @skill.abbr
  end

  test "should get destroy" do
    assert_difference 'Skill.count', -1 do
      delete :destroy, rule_set_id: @rule_set, id: @skill
    end
    assert_redirected_to rule_set_skills_path(@rule_set)
  end

end
