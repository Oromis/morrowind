require 'test_helper'

class ResistancesControllerTest < ActionController::TestCase
  def setup
    @gm = users(:arian)
    @resi = properties(:fire)
    @rule_set = rule_sets(:one)
    log_in_as @gm
  end

  test "should get index" do
    get :index, rule_set_id: @rule_set
    assert_response :success
    assert_template 'resistances/index'
  end

  test "should get new" do
    get :new, rule_set_id: @rule_set
    assert_response :success
    assert_template 'resistances/new'
  end

  test "should get create" do
    assert_difference 'Resistance.count', 1 do
      post :create, rule_set_id: @rule_set, resistance: { name: 'abc', abbr: 'a', default_value: 20, rule_set_id: @rule_set }
    end
    assert_redirected_to rule_set_resistances_path(@rule_set)
  end

  test "should get edit" do
    get :edit, rule_set_id: @rule_set, id: @resi
    assert_response :success
    assert_template 'resistances/edit'
  end

  test "should get update" do
    name = 'abc'
    abbr = 'a'
    patch :update, rule_set_id: @rule_set, id: @resi, resistance: { name: name, abbr: abbr }
    @resi.reload
    assert_equal name, @resi.name
    assert_equal abbr, @resi.abbr
    assert_redirected_to rule_set_resistances_path(@rule_set)
  end

  test "should get destroy" do
    assert_difference 'Resistance.count', -1 do
      delete :destroy, rule_set_id: @rule_set, id: @resi.id
    end
    assert_redirected_to rule_set_resistances_path(@rule_set)
  end
end
