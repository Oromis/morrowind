require 'test_helper'

class SpecializationsControllerTest < ActionController::TestCase
  def setup
    @rule_set = rule_sets(:one)
    @spec = specializations(:mage)
    @gm = users(:arian)

    log_in_as @gm
  end

  test "should get index" do
    get :index, rule_set_id: @rule_set
    assert_response :success
    assert_not_nil assigns(:specializations)
  end

  test "should get new" do
    get :new, rule_set_id: @rule_set
    assert_response :success
  end

  test "should create spec" do
    spec = @rule_set.specializations.new(name: 'Test Spec')
    assert_difference 'Specialization.count' do
      post :create, rule_set_id: @rule_set, specialization: { name: spec.name, rule_set_id: @rule_set.id }
    end

    assert_redirected_to rule_set_specializations_path(@rule_set)
  end

  test "should update spec" do
    name = 'Spock'
    patch :update, rule_set_id: @rule_set, id: @spec, specialization: { name: name, rule_set_id: @rule_set.id }
    @spec.reload
    assert_equal name, @spec.name
    assert_redirected_to rule_set_specializations_path(@rule_set)
  end

  test "should destroy spec" do
    assert_difference 'Specialization.count', -1 do
      delete :destroy, rule_set_id: @rule_set, id: @spec
    end

    assert_redirected_to rule_set_specializations_path(@rule_set)
  end

  test "should get edit" do
    get :edit, rule_set_id: @rule_set, id: @spec
    assert_response :success
  end

  test "should get show" do
    get :show, rule_set_id: @rule_set, id: @spec
    assert_response :success
  end

end
