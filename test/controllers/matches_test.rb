require 'test_helper'

class MatchesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @team1 = teams(:one)
    @team2 = teams(:two)
    @player = players(:one)
    @contract = PlayerContract.create!(player: @player, team: @team1, matches_played: 4, contract_length: 5, is_expired: false)
    @wallet = wallets(:one)
    sign_in @user
  end

  test "should increment matches_played and expire contract automatically" do
    initial_balance = @wallet.balance
    post create_simulation_matches_path, params: { team1_id: @team1.id, team2_id: @team2.id }
    assert_redirected_to match_path(Match.last)
    assert_equal 5, @contract.reload.matches_played
    assert_equal true, @contract.is_expired
    assert_equal true, @player.reload.is_on_market
    assert_equal initial_balance + @player.price, @wallet.reload.balance
    assert_equal 1, PlayerCooldown.where(player: @player, team: @team1, matches_remaining: 5).count
  end
end
