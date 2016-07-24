require 'test_helper'

class CharactersControllerTest < ActionController::TestCase
  def setup
    @user = users(:david)
    @rule_set = rule_sets(:one)
    @race = races(:dunmer)
  end

  test "index should work" do
    log_in_as @user
    get :index, user_id: @user
    assert_template 'characters/index'
    assert_response :success
  end

  test "new page should work" do
    log_in_as @user
    get :new, user_id: @user
    assert_template 'characters/new'
    assert_response :success
  end

  test "should redirect if not logged in" do
    get :index, user_id: @user
    assert_redirected_to login_url
    assert_not flash[:danger].empty?

    get :new, user_id: @user
    assert_redirected_to login_url
    assert_not flash[:danger].empty?
  end

  test "can create character" do
    log_in_as @user
    assert_difference 'Character.count', 1 do
      post :create, user_id: @user, character: { name: 'Nazir', rule_set_id: @rule_set.id, race_id: @race.id }
    end
  end
end
