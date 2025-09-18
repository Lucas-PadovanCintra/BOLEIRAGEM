class AddEloSystemToTeamsAndMatches < ActiveRecord::Migration[7.1]
  def change
    # Adicionar campos ELO para teams
    add_column :teams, :elo_rating, :integer, default: 1000, null: false
    add_column :teams, :matches_won, :integer, default: 0, null: false
    add_column :teams, :matches_lost, :integer, default: 0, null: false
    add_column :teams, :matches_drawn, :integer, default: 0, null: false
    add_column :teams, :highest_elo, :integer, default: 1000, null: false

    # Adicionar campos para matches
    add_column :matches, :team1_elo_before, :integer
    add_column :matches, :team2_elo_before, :integer
    add_column :matches, :team1_elo_change, :integer
    add_column :matches, :team2_elo_change, :integer
    add_column :matches, :reward_amount, :integer

    # Índices para melhor performance
    add_index :teams, :elo_rating
  end
end