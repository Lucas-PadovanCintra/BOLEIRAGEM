# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'

puts "Deleting players..."
Player.destroy_all

puts "Creating players..."
CSV.foreach(Rails.root.join('db/players.csv'), headers: true) do |row|
  Player.create!(
    name: row['name'],
    real_team_name: row['real_team_name'],
    position: row['position'],
    goals: row['goals'].to_i,
    assists: row['assists'].to_i,
    successful_dribbles: row['successful_dribbles'].to_i,
    interceptions: row['interceptions'].to_i,
    yellow_cards: row['yellow_cards'].to_i,
    red_cards: row['red_cards'].to_i,
    faults_committed: row['faults_committed'].to_i,
    loss_of_possession: row['loss_of_possession'].to_i,
    frequency_in_field: row['frequency_in_field'].to_i,
    rating: row['rating'].to_f,
    price: row['price'].to_i,
    is_on_market: true
  )
end

puts "Players created!"
