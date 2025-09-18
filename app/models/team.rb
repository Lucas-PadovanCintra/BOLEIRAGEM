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

  def division
    EloService.get_division(elo_rating)
  end

  def division_name
    division[:name]
  end

  def division_key
    division[:key]
  end

  def total_matches_played
    matches_won + matches_lost + matches_drawn
  end

  def win_rate
    return 0 if total_matches_played == 0
    ((matches_won.to_f / total_matches_played) * 100).round(1)
  end

  def recent_matches(limit = 5)
    matches.order(created_at: :desc).limit(limit)
  end

  def elo_history
    matches.order(created_at: :asc).map do |match|
      if match.match_teams.find_by(team: self).is_team1
        {
          match_id: match.id,
          elo_before: match.team1_elo_before,
          elo_change: match.team1_elo_change,
          result: match.team1_score > match.team2_score ? 'win' : (match.team1_score < match.team2_score ? 'loss' : 'draw'),
          created_at: match.created_at
        }
      else
        {
          match_id: match.id,
          elo_before: match.team2_elo_before,
          elo_change: match.team2_elo_change,
          result: match.team2_score > match.team1_score ? 'win' : (match.team2_score < match.team1_score ? 'loss' : 'draw'),
          created_at: match.created_at
        }
      end
    end.compact
  end

  def team_strength
    players = active_players
    return 0 if players.empty?

    total_rating = players.sum(:rating)
    (total_rating / players.count).round(1)
  end
end
