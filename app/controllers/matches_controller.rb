class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: [:show, :edit, :update, :destroy, :simulate]

  def index
    #@matches = Match.all
    @matches = current_user.matches.includes(match_teams: :team)
  end

  def show
  end

  def new
    @match = Match.new
  end

  def create
    @match = Match.new(match_params)

    if @match.save
      redirect_to @match, notice: 'Partida criada com sucesso.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @match.update(match_params)
      redirect_to @match, notice: 'Partida atualizada com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @match.destroy
    redirect_to matches_url, notice: 'Partida deletada com sucesso.'
  end

  def new_simulation
    @teams = Team.includes(:players)
    @match = Match.new
  end

  def create_simulation
    team1 = Team.find(params[:team1_id])
    team2 = Team.find(params[:team2_id])

    if team1 == team2
      redirect_to new_simulation_matches_path, alert: 'Selecione dois times diferentes.'
      return
    end

    ActiveRecord::Base.transaction do
      @match = Match.create!
      @match.match_teams.create!(team: team1, is_team1: true)
      @match.match_teams.create!(team: team2, is_team1: false)

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
    redirect_to new_simulation_matches_path, alert: "Erro na simulação: #{e.message}"
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

  def match_params
    params.require(:match).permit(:result)
  end
end
