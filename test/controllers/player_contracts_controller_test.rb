require "test_helper"

class PlayerContractsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get player_contracts_index_url
    assert_response :success
  end

  test "should get show" do
    get player_contracts_show_url
    assert_response :success
  end

  test "should get new" do
    get player_contracts_new_url
    assert_response :success
  end

  test "should get create" do
    get player_contracts_create_url
    assert_response :success
  end

  test "should get edit" do
    get player_contracts_edit_url
    assert_response :success
  end

  test "should get update" do
    get player_contracts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get player_contracts_destroy_url
    assert_response :success
  end
end
