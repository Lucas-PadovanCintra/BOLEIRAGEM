class PlayerContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_player_contract, only: [:show, :edit, :update, :destroy]

  def index
    @player_contracts = PlayerContract.joins(:team).where(teams: { user: current_user })
  end

  def show
  end

  def new
    @player_contract = PlayerContract.new
    @teams = current_user.teams
    @players = Player.where(is_on_market: true)
  end

  def create
    @player_contract = PlayerContract.new(player_contract_params)
    
    if @player_contract.save
      redirect_to @player_contract, notice: 'Player contract was successfully created.'
    else
      @teams = current_user.teams
      @players = Player.where(is_on_market: true)
      render :new
    end
  end

  def edit
    @teams = current_user.teams
    @players = Player.all
  end

  def update
    if @player_contract.update(player_contract_params)
      redirect_to @player_contract, notice: 'Player contract was successfully updated.'
    else
      @teams = current_user.teams
      @players = Player.all
      render :edit
    end
  end

  def destroy
    @player_contract.destroy
    redirect_to player_contracts_url, notice: 'Player contract was successfully deleted.'
  end

  private

  def set_player_contract
    @player_contract = PlayerContract.joins(:team).where(teams: { user: current_user }).find(params[:id])
  end

  def player_contract_params
    params.require(:player_contract).permit(:player_id, :team_id, :matches_played, :contract_length, :is_expired)
  end
end
