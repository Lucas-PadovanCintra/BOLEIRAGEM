class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: [:show, :destroy]
  before_action :set_user_teams, only: [:index]

  def index




    @matches = current_user.matches.includes(match_teams: :team).order(created_at: :desc)
    @matches = @matches.where(result: params[:status]) if params[:status].present?

    # Find team in queue first, then fallback to param or first team
    team_in_queue = current_user.teams.joins(:team_matchmaking_queues)
                                      .where(team_matchmaking_queues: { status: 'waiting' })
                                      .first

    if team_in_queue
      @selected_team = team_in_queue
    elsif params[:team_id].present?
      @selected_team = current_user.teams.find_by(id: params[:team_id])
    else
      @selected_team = current_user.teams.first
    end

    @in_queue = @selected_team&.in_matchmaking_queue?

    Rails.logger.info "MatchesController#index - Selected team: #{@selected_team&.name}, In queue: #{@in_queue}"

  end

  #gostaria que fosse assim, mas n ta funcionando
  #def index
  #@matches = current_user.matches.includes(match_teams: :team).recent
  #@matches = @matches.by_status(params[:status])
#end

  def show
  end

  def destroy
    @match.destroy
    redirect_to matches_url, notice: 'Partida deletada com sucesso.'
  end

  def make_available
    team = current_user.teams.find(params[:team_id])
    result = MatchmakingService.add_to_queue(team, current_user)

    if result[:error]
      redirect_to matches_path(team_id: team.id), alert: result[:error]
    elsif result[:matched]
      redirect_to result[:match], notice: 'Partida encontrada e simulada automaticamente!'
    else
      redirect_to matches_path(team_id: team.id), notice: 'Time adicionado à fila de espera. Você será notificado quando uma partida for encontrada.'
    end
  end

  def remove_from_queue
    team = current_user.teams.find(params[:team_id])
    result = MatchmakingService.remove_from_queue(team)

    if result[:error]
      redirect_to matches_path(team_id: team.id), alert: result[:error]
    else
      redirect_to matches_path(team_id: team.id), notice: 'Time removido da fila de espera.'
    end

    ActiveRecord::Base.transaction do
      @match = Match.create!
      @match.match_teams.create!(team: team1, is_team1: true)
      @match.match_teams.create!(team: team2, is_team1: false)

      simulator = MatchSimulator.new(team1, team2)
      result = simulator.simulate


      @match.update!(
        result: result[:status],
        team1_score: result[:team1_score],
        team2_score: result[:team2_score],
        winner_team: result[:winner],
        is_simulated: true,
        simulation_stats: result[:stats],
      )

      # Aqui adicionamos a lógica para atualizar o saldo
      if result[:winner]
        update_wallet_winner(result[:winner])
      end

      # Incrementar matches_played e gerenciar expirações
      [team1, team2].each do |team|
        team.player_contracts.where(is_expired: false).each do |contract|
          contract.increment!(:matches_played)
          if contract.matches_played >= contract.contract_length
            contract.update!(is_expired: true)
            contract.player.update!(is_on_market: true)
            user_wallet = team.user.wallet
            user_wallet.update!(balance: user_wallet.balance + contract.player.price)
            PlayerCooldown.create!(player: contract.player, team: team, matches_remaining: 5)
          end
        end
        # Decrementar cooldowns
        team.player_cooldowns.each do |cooldown|
          cooldown.decrement!(:matches_remaining)
        end
      end
    end

    redirect_to @match, notice: 'Simulação realizada com sucesso!'
  rescue => e
    redirect_to new_simulation_matches_path, alert: "Erro na simulação: #{e.message}"
  end

  def update_wallet_winner(winner_team)
    wallet = winner_team.user.wallet
    reward_amount = 100  # Defina o valor da recompensa
    wallet.update!(balance: wallet.balance + reward_amount)
  end

  def simulate
    if @match.is_simulated
      redirect_to @match, alert: 'Esta partida já foi simulada.'
      return
    end

    team1 = @match.team1
    team2 = @match.team2

    unless team1 && team2
      redirect_to @match, alert: 'A partida precisa ter dois times associados.'
      return
    end

    ActiveRecord::Base.transaction do
      simulator = MatchSimulator.new(team1, team2)
      result = simulator.simulate

      @match.update!(
        team1_score: result[:team1_score],
        team2_score: result[:team2_score],
        winner_team: result[:winner],
        is_simulated: true,
        simulation_stats: result[:stats]
      )



      # Incrementar matches_played e gerenciar expirações
      [team1, team2].each do |team|
        team.player_contracts.where(is_expired: false).each do |contract|
          contract.increment!(:matches_played)
          if contract.matches_played >= contract.contract_length
            contract.update!(is_expired: true)
            contract.player.update!(is_on_market: true)
            user_wallet = team.user.wallet
            user_wallet.update!(balance: user_wallet.balance + contract.player.price)
            PlayerCooldown.create!(player: contract.player, team: team, matches_remaining: 5)
          end
        end
        # Decrementar cooldowns
        team.player_cooldowns.each do |cooldown|
          cooldown.decrement!(:matches_remaining)
        end
      end
    end

    redirect_to @match, notice: 'Simulação realizada com sucesso!'
  rescue => e
    redirect_to @match, alert: "Erro na simulação: #{e.message}"
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def set_user_teams
    @user_teams = current_user.teams.includes(:players)
  end

end
