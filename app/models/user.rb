class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :teams, dependent: :destroy
  has_one :wallet, dependent: :destroy
  #validates :wallet, presence: true
  after_create :create_wallet

  private

  def create_wallet
    Wallet.create!(user: self, balance: 1000)
  end

end
