class PlayersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_player, only: [:show, :edit, :update, :destroy]

  def index
    @q = Player.where(is_on_market: true).ransack(params[:q]) # Filtra apenas disponíveis
    @players = @q.result(distinct: true).page(params[:page]) # .order(name: :asc) .per(20)
  end

  def show
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to @player, notice: 'Player was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @player.update(player_params)
      redirect_to @player, notice: 'Player was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @player.destroy
    redirect_to players_url, notice: 'Player was successfully deleted.'
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:assists, :faults_committed, :frequency_in_field, :goals, :interceptions, :is_on_market, :loss_of_possession, :name, :price, :rating, :real_team_name, :red_cards, :successful_dribbles, :yellow_cards)
  end
end
