class Team < ApplicationRecord
  belongs_to :user
  has_many :player_contracts, dependent: :destroy
  has_many :players, through: :player_contracts
  has_many :match_teams, dependent: :destroy
  has_many :matches, through: :match_teams

  validates :name, presence: true

  def valid_team?
    players_count = players.count
    players_count >= 1 && players_count <= 11
  end
end
