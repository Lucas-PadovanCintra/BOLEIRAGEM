class Player < ApplicationRecord
  has_many :player_contracts, dependent: :destroy
  has_many :teams, through: :player_contracts

  validates :name, presence: true
  validates :rating, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :position, inclusion: { in: %w[goleiro zagueiro lateral-direito lateral-esquerdo volante meia atacante], message: "deve ser uma posição válida" }

  def self.ransackable_attributes(auth_object = nil)
    ["assists", "created_at", "faults_committed", "frequency_in_field", "goals", "id", "interceptions", "is_on_market", "loss_of_possession", "name", "position", "price", "rating", "real_team_name", "red_cards", "successful_dribbles", "updated_at", "yellow_cards"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["player_contracts", "teams"]
  end
end
