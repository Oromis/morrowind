require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:david)
    @other_user = users(:mosl)
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_template 'users/new'
  end

  test "should redirect edit" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect when edit wrong user" do
    log_in_as(@other_user)
    get :edit, id: @user
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect when update wrong user" do
    log_in_as(@other_user)
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

  test "normal user cannot change role" do
    log_in_as(@other_user)
    old_role = @other_user.role
    patch :update, id: @other_user, user: { name: @other_user.name, 
                                            email: @other_user.email,
                                            role: 'admin' }
    @other_user.reload
    assert_equal old_role, @other_user.role
    assert_equal 'guest', @other_user.role
  end

  test "admin can change role" do
    log_in_as(@user)
    patch :update, id: @other_user, user: { name: @other_user.name,
                                            email: @other_user.email,
                                            role: 'admin' }
    @other_user.reload
    assert_equal 'admin', @other_user.role
  end
end
