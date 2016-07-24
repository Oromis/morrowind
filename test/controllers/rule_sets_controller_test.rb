require 'test_helper'

class RuleSetsControllerTest < ActionController::TestCase
  include SessionsHelper

  setup do
    @rule_set = rule_sets(:one)
    @normal_user = users(:mosl)
    @gm = users(:arian)
    log_in_as @gm
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rule_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rule_set" do
    assert_difference('RuleSet.count') do
      post :create, rule_set: { version: @rule_set.version }
    end

    assert_redirected_to rule_set_path(assigns(:rule_set))
  end

  test "should show rule_set" do
    get :show, id: @rule_set
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rule_set
    assert_response :success
  end

  test "should update rule_set" do
    patch :update, id: @rule_set, rule_set: { version: @rule_set.version }
    assert_redirected_to edit_rule_set_path(assigns(:rule_set))
  end

  test "should destroy rule_set" do
    assert_difference('RuleSet.count', -1) do
      delete :destroy, id: @rule_set
    end

    assert_redirected_to rule_sets_path
  end

  test "login required" do
    log_out
    assert_logged_in :get, :index
    assert_logged_in :get, :new, gm_required: true
    assert_logged_in :post, :create, rule_set: { version: @rule_set.version }, gm_required: true
    assert_logged_in :get, :edit, id: @rule_set, gm_required: true
    assert_logged_in :patch, :update, id: @rule_set, rule_set: { version: @rule_set.version }, gm_required: true
    assert_logged_in :delete, :destroy, id: @rule_set, gm_required: true
  end

  def assert_logged_in(method, path, options = {})
    assert_no_difference 'RuleSet.count' do
      send method, path, options
      assert_redirected_to login_url
    end
    if options[:gm_required]
      log_in_as @normal_user
      assert_no_difference 'RuleSet.count' do
        send method, path, options
        assert_redirected_to login_url
      end
      log_out
    end
  end
end
