class WalletsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wallet

  def show
  end

  def update
    if @wallet.update(wallet_params)
      redirect_to @wallet, notice: 'Wallet was successfully updated.'
    else
      render :show
    end
  end

  private

  def set_wallet
    if current_user.wallet.nil?
      new_wallet = Wallet.create!(user_id: current_user.id, balance: 1000)
      @wallet = new_wallet
    else
      @wallet = current_user.wallet
  end

  def wallet_params
    params.require(:wallet).permit(:balance)
  end
end
