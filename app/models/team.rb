class Team < ApplicationRecord
  belongs_to :user
  has_many :player_contracts, dependent: :destroy
  has_many :players, through: :player_contracts
  has_many :active_player_contracts, -> { where(is_expired: false) }, class_name: 'PlayerContract'
  has_many :active_players, through: :active_player_contracts, source: :player
  has_many :match_teams, dependent: :destroy
  has_many :matches, through: :match_teams
  has_many :player_cooldowns, dependent: :destroy # Adicionada associação
  has_many :team_matchmaking_queues, dependent: :destroy

  validates :name, presence: true

  def valid_team?
    players_count = active_players.count
    players_count >= 1 && players_count <= 11
  end

  def in_matchmaking_queue?
    team_matchmaking_queues.waiting.exists?
  end

  def current_queue_entry
    team_matchmaking_queues.waiting.first
  end
end
