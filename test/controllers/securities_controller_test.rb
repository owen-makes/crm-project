require "test_helper"

class SecuritiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get securities_index_url
    assert_response :success
  end

  test "should get show" do
    get securities_show_url
    assert_response :success
  end
end
