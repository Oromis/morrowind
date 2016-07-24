require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:david)
    @non_admin = users(:arian)
    @non_gm = users(:mosl)
  end

  test "index" do
    log_in_as @non_admin
    get users_path
    assert_template 'users/index'
    User.all.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
    assert_select 'a', text: 'Löschen', count: 0 # Should not see delete links
  end

  test "admin can delete users" do
    log_in_as @admin
    get users_path
    User.all.each do |user|
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), { text: 'Löschen' }, 
          "No delete link for user #{user.name}"
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "normal user cannot gain admin privilleges" do
    log_in_as @non_admin
    get users_path
    patch user_path(@non_admin), user: { name: @non_admin.name, 
                                         email: @non_admin.email,
                                         role: 'admin' }
    assert_not @non_admin.reload.admin?
  end

  test "normal user cannot see index" do
    log_in_as @non_gm
    get users_path
    assert_redirected_to root_url
  end
end
