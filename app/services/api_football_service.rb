class ApiFootballService
  include HTTParty
  base_uri 'https://v3.football.api-sports.io'

  def initialize
    @headers = {
      'x-apisports-key' => ENV['API_FOOTBALL_KEY']
    }
  end

  def fetch_players(league_id, season, page = 1)
    self.class.get("/players?league=#{league_id}&season=#{season}&page=#{page}", headers: @headers)
  end

  def fetch_teams(league_id, season)
    self.class.get("/teams?league=#{league_id}&season=#{season}", headers: @headers)
  end
end
