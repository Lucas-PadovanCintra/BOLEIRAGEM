class Player < ApplicationRecord
  has_many :player_contracts, dependent: :destroy
  has_many :teams, through: :player_contracts

  validates :api_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :rating, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
end
