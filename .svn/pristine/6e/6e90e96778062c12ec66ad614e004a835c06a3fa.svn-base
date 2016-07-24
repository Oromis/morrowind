require 'test_helper'

class BirthsignsControllerTest < ActionController::TestCase
  setup do
    @rule_set = rule_sets(:one)
    @birthsign = birthsigns(:warrior)
    @gm = users(:arian)

    log_in_as @gm
  end

  test "should get index" do
    get :index, rule_set_id: @rule_set
    assert_response :success
    assert_not_nil assigns(:birthsigns)
  end

  test "should get new" do
    get :new, rule_set_id: @rule_set
    assert_response :success
  end

  test "should create birthsign" do
    birthsign = @rule_set.birthsigns.new(name: 'Testoiden')
    assert_difference('Birthsign.count') do
      post :create, rule_set_id: @rule_set, birthsign: { name: birthsign.name, rule_set_id: @rule_set.id }
    end

    assert_redirected_to rule_set_birthsign_path(@rule_set, assigns(:birthsign))
  end

  test "should show birthsign" do
    get :show, rule_set_id: @rule_set, id: @birthsign
    assert_response :success
  end

  test "should get edit" do
    get :edit, rule_set_id: @rule_set, id: @birthsign
    assert_response :success
  end

  test "should update birthsign" do
    patch :update, rule_set_id: @rule_set, id: @birthsign, birthsign: { name: 'Testoids', rule_set_id: @rule_set.id }
    assert_redirected_to rule_set_birthsign_path(@rule_set, @birthsign)
  end

  test "should destroy birthsign" do
    assert_difference('Birthsign.count', -1) do
      delete :destroy, rule_set_id: @rule_set, id: @birthsign
    end

    assert_redirected_to rule_set_birthsigns_path(@rule_set)
  end
end
