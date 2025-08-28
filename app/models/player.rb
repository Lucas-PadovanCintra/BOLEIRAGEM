class Player < ApplicationRecord
  has_many :player_contracts, dependent: :destroy
  has_many :teams, through: :player_contracts

  validates :api_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :rating, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }

  def self.ransackable_attributes(auth_object = nil)
    ["api_id", "created_at", "id", "id_value", "is_on_market", "name", "price", "rating", "real_team_name", "updated_at"]
  end
end
