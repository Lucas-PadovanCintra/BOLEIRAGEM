class MatchTeam < ApplicationRecord
  belongs_to :match
  belongs_to :team

  validates :is_team1, inclusion: { in: [true, false] }
end

