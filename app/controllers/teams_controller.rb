class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  def index
    @teams = current_user.teams
  end

  def show
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
    params.require(:team).permit(:name)
  end
end
