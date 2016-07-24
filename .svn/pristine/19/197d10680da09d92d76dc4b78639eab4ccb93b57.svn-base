require 'test_helper'

class RacesControllerTest < ActionController::TestCase
  setup do
    @rule_set = rule_sets(:one)
    @race = races(:redguard)
    @gm = users(:arian)

    log_in_as @gm
  end

  test "should get index" do
    get :index, rule_set_id: @rule_set
    assert_response :success
    assert_not_nil assigns(:races)
  end

  test "should get new" do
    get :new, rule_set_id: @rule_set
    assert_response :success
  end

  test "should create race" do
    race = @rule_set.races.new(name: 'Testoiden')
    assert_difference('Race.count') do
      post :create, rule_set_id: @rule_set, race: { name: race.name, rule_set_id: @rule_set.id }
    end

    assert_redirected_to rule_set_race_path(@rule_set, assigns(:race))
  end

  test "should show race" do
    get :show, rule_set_id: @rule_set, id: @race
    assert_response :success
  end

  test "should get edit" do
    get :edit, rule_set_id: @rule_set, id: @race
    assert_response :success
  end

  test "should update race" do
    patch :update, rule_set_id: @rule_set, id: @race, race: { name: 'Testoids', rule_set_id: @rule_set.id }
    assert_redirected_to rule_set_race_path(@rule_set, @race)
  end

  test "should destroy race" do
    assert_difference('Race.count', -1) do
      delete :destroy, rule_set_id: @rule_set, id: @race
    end

    assert_redirected_to rule_set_races_path(@rule_set)
  end
end
