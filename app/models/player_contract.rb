class PlayerContract < ApplicationRecord
  belongs_to :player
  belongs_to :team
  has_many :matches, through: :team

  validates :matches_played, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :contract_length, presence: true, numericality: { greater_than: 0 }
  validates :is_expired, inclusion: { in: [true, false] }

  after_create :mark_player_as_unavailable
  after_update :update_player_market_status

  private

  def mark_player_as_unavailable
    player.update(is_on_market: false)
  end

  def update_player_market_status
    if saved_change_to_is_expired? && is_expired?
      player.update(is_on_market: true)
    end
  end
end
