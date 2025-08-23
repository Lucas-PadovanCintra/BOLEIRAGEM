class PlayerContract < ApplicationRecord
  belongs_to :player
  belongs_to :team

  validates :matches_played, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :contract_length, presence: true, numericality: { greater_than: 0 }
  validates :is_expired, inclusion: { in: [true, false] }
end
