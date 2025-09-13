class TeamMatchmakingQueue < ApplicationRecord
  belongs_to :team
  belongs_to :user
  belongs_to :match, optional: true

  validates :status, presence: true, inclusion: { in: %w[waiting matched cancelled] }
  validates :team_id, uniqueness: { scope: :status, message: "já está na fila de espera" }, if: -> { status == 'waiting' }
  
  validate :team_must_have_players, on: :create

  scope :waiting, -> { where(status: 'waiting') }
  scope :matched, -> { where(status: 'matched') }
  scope :not_from_team, ->(team_id) { where.not(team_id: team_id) }
  scope :oldest_first, -> { order(created_at: :asc) }

  private

  def team_must_have_players
    if team && team.active_players.count == 0
      errors.add(:team, "deve ter pelo menos um jogador com contrato ativo para entrar na fila")
    end
  end
end