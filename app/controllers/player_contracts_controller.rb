class PlayerContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_player_contract, only: [:show, :edit, :update, :destroy, :expire]

  def index
    @player_contracts = PlayerContract.joins(:team).where(teams: { user: current_user }, is_expired: false)
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
      redirect_to @player_contract, notice: 'Contrato criado com sucesso.'
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
      redirect_to @player_contract, notice: 'Contrato atualizado com sucesso.'
    else
      @teams = current_user.teams
      @players = Player.all
      render :edit
    end
  end

  def destroy
    @player_contract.destroy
    redirect_to player_contracts_url, notice: 'Contrato deletado com sucesso.'
  end

  def expire
    if @player_contract.is_expired?
      render json: { error: 'Este contrato já está expirado.' }, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      @player_contract.update!(is_expired: true)
      @player_contract.player.update!(is_on_market: true)
      user_wallet = @player_contract.team.user.wallet
      user_wallet.update!(balance: user_wallet.balance + @player_contract.player.price)
      PlayerCooldown.create!(player: @player_contract.player, team: @player_contract.team, matches_remaining: 5)
    end

    render json: { notice: 'Contrato expirado com sucesso!' }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "Erro ao expirar contrato: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def set_player_contract
    @player_contract = PlayerContract.joins(:team).where(teams: { user: current_user }).find(params[:id])
  end

  def player_contract_params
    params.require(:player_contract).permit(:player_id, :team_id, :matches_played, :contract_length, :is_expired)
  end
end
