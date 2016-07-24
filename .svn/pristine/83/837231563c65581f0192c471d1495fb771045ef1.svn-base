require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", full_title
  end

  test "should get contact" do
    get :contact
    assert_response :success
    assert_template 'static_pages/contact'
    assert_select "title", full_title("Kontakt")
  end

end
