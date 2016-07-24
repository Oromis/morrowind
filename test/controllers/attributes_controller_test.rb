require 'test_helper'

class AttributesControllerTest < ActionController::TestCase
  def setup
    @gm = users(:arian)
    @attr = properties(:str)
    @rule_set = rule_sets(:one)
    log_in_as @gm
  end

  test "should get index" do
    get :index, rule_set_id: @rule_set
    assert_response :success
    assert_template 'attributes/index'
  end

  test "should get new" do
    get :new, rule_set_id: @rule_set
    assert_response :success
    assert_template 'attributes/new'
  end

  test "should get create" do
    assert_difference 'Attribute.count', 1 do
      post :create, rule_set_id: @rule_set, attribute: { name: 'abc', abbr: 'a', default_value: 20, rule_set_id: @rule_set }
    end
    assert_redirected_to rule_set_attributes_path(@rule_set)
  end

  test "should get edit" do
    get :edit, rule_set_id: @rule_set, id: @attr
    assert_response :success
    assert_template 'attributes/edit'
  end

  test "should get update" do
    name = 'abc'
    abbr = 'a'
    patch :update, rule_set_id: @rule_set, id: @attr, attribute: { name: name, abbr: abbr }
    @attr.reload
    assert_equal name, @attr.name
    assert_equal abbr, @attr.abbr
    assert_redirected_to rule_set_attributes_path(@rule_set)
  end

  test "should get destroy" do
    assert_difference 'Attribute.count', -1 do
      delete :destroy, rule_set_id: @rule_set, id: @attr.id
    end
    assert_redirected_to rule_set_attributes_path(@rule_set)
  end

end
