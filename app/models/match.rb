class Match < ApplicationRecord
  has_many :match_teams, dependent: :destroy
  has_many :teams, through: :match_teams
  belongs_to :winner_team, class_name: 'Team', optional: true

  scope :simulated, -> { where(is_simulated: true) }
  scope :not_simulated, -> { where(is_simulated: false) }

  def team1
    match_teams.find_by(is_team1: true)&.team
  end

  def team2
    match_teams.find_by(is_team1: false)&.team
  end

  def draw?
    is_simulated && team1_score == team2_score
  end

  def winner_name
    return "Empate" if draw?
    winner_team&.name
  end
end
