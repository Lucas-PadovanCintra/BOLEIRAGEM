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

  setup do
    @user = users(:one)
    @team = teams(:one)
    @player = players(:one)
    @wallet = wallets(:one)
    sign_in @user
  end

  test "should create contract and deduct balance" do
    assert_difference 'PlayerContract.count', 1 do
      assert_difference '@wallet.reload.balance', -@player.price do
        post purchase_player_path(@player)
      end
    end
    assert_equal false, @player.reload.is_on_market
    assert_redirected_to players_path
    follow_redirect!
    assert_select 'div.alert', /foi contratado com sucesso/
  end

  test "should block purchase during cooldown" do
    PlayerContract.create!(player: @player, team: @team, matches_played: 5, contract_length: 5, is_expired: true)
    PlayerCooldown.create!(player: @player, team: @team, matches_remaining: 3)
    post purchase_player_path(@player)
    assert_redirected_to players_path
    follow_redirect!
    assert_select 'div.alert', /indisponível por 3 partidas/
  end

  test "should expire contract manually and create cooldown" do
    contract = PlayerContract.create!(player: @player, team: @team, matches_played: 2, contract_length: 5, is_expired: false)
    initial_balance = @wallet.balance
    post player_contract_expire_path(contract), headers: { 'ACCEPT' => 'application/json' }
    assert_response :success
    assert_equal true, contract.reload.is_expired
    assert_equal true, @player.reload.is_on_market
    assert_equal initial_balance + @player.price, @wallet.reload.balance
    assert_equal 1, PlayerCooldown.where(player: @player, team: @team, matches_remaining: 5).count
  end
end
