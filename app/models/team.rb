class Team < ApplicationRecord
  belongs_to :user
  has_many :player_contracts, dependent: :destroy
  has_many :players, through: :player_contracts
  has_many :match_teams, dependent: :destroy
  has_many :matches, through: :match_teams
  has_many :player_cooldowns, dependent: :destroy # Adicionada associação

  validates :name, presence: true
end
