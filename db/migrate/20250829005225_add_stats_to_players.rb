class AddStatsToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :goals, :integer
    add_column :players, :assists, :integer
    add_column :players, :successful_dribbles, :integer
    add_column :players, :interceptions, :integer
    add_column :players, :yellow_cards, :integer
    add_column :players, :red_cards, :integer
    add_column :players, :faults_committed, :integer
    add_column :players, :loss_of_possession, :integer
    add_column :players, :frequency_in_field, :integer
  end
end
