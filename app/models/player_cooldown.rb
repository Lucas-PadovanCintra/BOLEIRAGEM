class PlayerCooldown < ApplicationRecord
  belongs_to :player
  belongs_to :team

  validates :matches_remaining, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :player_id, uniqueness: { scope: :team_id, message: "indisponível temporariamente para este time" }

  after_update :remove_if_completed

  private

  def remove_if_completed
    destroy if matches_remaining <= 0
  end
end
