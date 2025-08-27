class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :teams, dependent: :destroy
  has_many :wallets, dependent: :destroy
  after_create :create_wallet

  def amount
    wallets.sum(:balance)
  end

  private

  def create_wallet
    wallet = Wallet.new(user: self)
    wallet.save!
  end

end
