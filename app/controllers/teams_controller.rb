class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  def index
    @teams = current_user.teams
  end

  def show
    active_contracts = @team.player_contracts.where(is_expired: false)
    all_rating = active_contracts.map do |contract|
      contract.player.rating
    end
    if active_contracts.length.positive?
      @avarege_rating = all_rating.sum / active_contracts.length
      @avarege_rating = sprintf('%.1f', @avarege_rating)
    else
      @avarege_rating = '0.0'
    end
    @team.player_contracts.includes(:player)
  end

  def new
    @team = current_user.teams.build
  end

  def create
    @team = current_user.teams.build(team_params)

    if @team.save
      redirect_to @team, notice: 'Team was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: 'Team was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: 'Team was successfully deleted.'
  end

  private

  def set_team
    @team = current_user.teams.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :description)
  end
end
