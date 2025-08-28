namespace :populate_players do
  desc "Populate players from API-Football Serie A 2023"
  task from_api: :environment do
    service = ApiFootballService.new
    league_id = 71
    season = 2023

    # Popular players (com time real como referência)
    page = 1
    loop do
      puts "Fetching players page #{page} for league #{league_id}, season #{season}..."
      response = service.fetch_players(league_id, season, page)
      puts "Players response code: #{response.code}"
      puts "Players response body: #{response.body}"

      if response.success? && response['response'].present?
        players = response['response']
        puts "Found #{players.size} players in page #{page}."
        players.each do |player_data|
          puts "Processing player: #{player_data['player']['name'] rescue 'Invalid player data'}"
          player = Player.find_or_initialize_by(api_id: player_data['player']['id'])
          rating = player_data['statistics'][0]['games']['rating']&.to_f || 6.0
          price = (rating * 13).round.to_i
          real_team_name = player_data['statistics'][0]['team']['name']

          player.update!(
            name: player_data['player']['name'],
            rating: rating.to_i,
            price: price,
            is_on_market: true,
            real_team_name: real_team_name
          )
        end
        puts "Populated page #{page} with #{players.size} players."
        break if response['paging']['current'] == response['paging']['total'] || page >= 3
        page += 1
      else
        puts "Error fetching players: #{response.code} - #{response.message}"
        puts "Response body: #{response.body}" if response.body.present?
        break
      end
    end
  end
end
