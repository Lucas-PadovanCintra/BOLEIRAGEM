class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: [:show, :destroy]
  before_action :set_user_teams, only: [:index]

  def index
    @matches = current_user.matches.includes(match_teams: :team)
    
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
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def set_user_teams
    @user_teams = current_user.teams.includes(:players)
  end

end
