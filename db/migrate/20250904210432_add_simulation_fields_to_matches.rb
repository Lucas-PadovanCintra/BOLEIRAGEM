class AddSimulationFieldsToMatches < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :team1_score, :integer
    add_column :matches, :team2_score, :integer
    add_reference :matches, :winner_team, null: true, foreign_key: { to_table: :teams }
    add_column :matches, :is_simulated, :boolean, default: false
    add_column :matches, :simulation_stats, :json
  end
end
