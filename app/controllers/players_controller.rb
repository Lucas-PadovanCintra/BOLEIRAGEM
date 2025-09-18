require 'will_paginate/active_record'

class PlayersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_player, only: [:show, :edit, :update, :destroy, :purchase]

  def index
    q_params = params[:q]&.permit! || {} # garante que q_params sempre seja um hash permitido

    @q = Player.ransack(q_params)

    if params[:filter_type]
      case params[:filter_type]
      when 'all'
        @q = Player.ransack({}) # Remove todos os filtros
      when 'available'
        @q = Player.ransack(is_on_market_eq: true)
      when 'contracted'
        @q = Player.ransack(is_on_market_eq: false)
      end
    end

    @players = @q.result(distinct: true).page(params[:page] || 1)
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

  def purchase
    unless @player.is_on_market?
      redirect_to players_path, alert: 'Este jogador não está disponível no mercado.'
      return
    end

    user_team = current_user.teams.first
    unless user_team
      redirect_to players_path, alert: 'Você precisa ter um time para contratar jogadores.'
      return
    end

    user_wallet = current_user.wallet
    unless user_wallet&.balance && user_wallet.balance >= @player.price
      redirect_to players_path, alert: 'Saldo insuficiente para contratar este jogador.'
      return
    end

    cooldown = PlayerCooldown.find_by(player: @player, team: user_team)
    if cooldown
      redirect_to players_path, alert: "Este jogador está indisponível por #{cooldown.matches_remaining} partidas."
      return
    end

    ActiveRecord::Base.transaction do
      user_wallet.update!(balance: user_wallet.balance - @player.price)

      # Registrar transação de compra
      user_wallet.transactions.create!(
        amount: -@player.price,
        transaction_type: 'player_purchase',
        category: 'player',
        description: "Contratação de #{@player.name} (#{@player.position})",
        player: @player,
        team: user_team,
        balance_after: user_wallet.balance
      )

      PlayerContract.create!(
        player: @player,
        team: user_team,
        matches_played: 0,
        contract_length: 5,
        is_expired: false
      )
      @player.update!(is_on_market: false)
    end

    redirect_to players_path, notice: "#{@player.name} foi contratado com sucesso!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to players_path, alert: "Erro ao contratar jogador: #{e.message}"
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:assists, :faults_committed, :frequency_in_field, :goals, :interceptions, :is_on_market, :loss_of_possession, :name, :position, :price, :rating, :real_team_name, :red_cards, :successful_dribbles, :yellow_cards)
  end
end
