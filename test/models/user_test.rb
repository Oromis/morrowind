require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup 
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobar",
                    password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = nil
    assert_not @user.valid?
    @user.name = ''
    assert_not @user.valid?
    @user.name = '    '
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "    "
    assert_not @user.name.empty?
    assert_not @user.valid?
  end

  test "name not too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email not too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email valid" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                             first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |addr|
      @user.email = addr
      assert @user.valid?, "#{addr.inspect} should be valid!"
    end
  end

  test "should reject invalid emails" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                               foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |addr|
      @user.email = addr
      assert_not @user.valid?, "#{addr.inspect} should be rejected!"
    end
  end

  test "should reject duplicate" do
    dup_user = @user.dup
    dup_user.email = @user.email.upcase
    @user.save
    assert_not dup_user.valid?
  end

  test "pw not empty" do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test "pw minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "has_role? should work properly" do
    @user.user!
    assert @user.has_role?(:user)
    assert_not @user.has_role?(:gm)
    assert_not @user.has_role?(:admin)

    @user.gm!
    assert @user.has_role?(:user)
    assert @user.has_role?(:gm)
    assert_not @user.has_role?(:admin)

    @user.admin!
    assert @user.has_role?(:user)
    assert @user.has_role?(:gm)
    assert @user.has_role?(:admin)
  end
end
