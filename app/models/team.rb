class Team < ApplicationRecord
  belongs_to :user
  has_many :player_contracts, dependent: :destroy
  has_many :players, through: :player_contracts
  has_many :match_teams, dependent: :destroy
  has_many :matches, through: :match_teams
  has_many :player_cooldowns, dependent: :destroy # Adicionada associação
  has_many :active_player_contracts,
  -> { active },
  class_name: 'PlayerContract'

  has_many :active_players,
  -> { distinct },
  through: :active_player_contracts,
  source: :player

  validates :name, presence: true

  def valid_team?
    players_count = players.count
    players_count >= 1 && players_count <= 11
  end
end
