require "test_helper"

class WebsiteControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get website_new_url
    assert_response :success
  end

  test "should get create" do
    get website_create_url
    assert_response :success
  end
end
