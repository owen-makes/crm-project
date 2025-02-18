require "test_helper"

class HoldingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get holdings_index_url
    assert_response :success
  end

  test "should get new" do
    get holdings_new_url
    assert_response :success
  end

  test "should get create" do
    get holdings_create_url
    assert_response :success
  end

  test "should get edit" do
    get holdings_edit_url
    assert_response :success
  end

  test "should get update" do
    get holdings_update_url
    assert_response :success
  end

  test "should get show" do
    get holdings_show_url
    assert_response :success
  end

  test "should get destroy" do
    get holdings_destroy_url
    assert_response :success
  end
end
