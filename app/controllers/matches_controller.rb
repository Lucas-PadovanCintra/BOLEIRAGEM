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
      redirect_to @match, notice: 'Match was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @match.update(match_params)
      redirect_to @match, notice: 'Match was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @match.destroy
    redirect_to matches_url, notice: 'Match was successfully deleted.'
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

    simulator = MatchSimulator.new(team1, team2)
    result = simulator.simulate

    @match.update!(
      team1_score: result[:team1_score],
      team2_score: result[:team2_score],
      winner_team: result[:winner],
      is_simulated: true,
      simulation_stats: result[:stats]
    )

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
