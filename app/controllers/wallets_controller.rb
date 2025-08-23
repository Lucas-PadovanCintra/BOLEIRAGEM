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
    @wallet = current_user.wallet || current_user.create_wallet
  end

  def wallet_params
    params.require(:wallet).permit(:balance)
  end
end
