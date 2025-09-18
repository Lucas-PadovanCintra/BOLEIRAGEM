class EloService
  K_FACTOR_NEW = 40    # Para times com menos de 30 partidas
  K_FACTOR_MID = 32    # Para times com 30-100 partidas
  K_FACTOR_PRO = 24    # Para times com mais de 100 partidas

  DIVISIONS = {
    bronze: { min: 0, max: 999, name: 'Bronze', multiplier: 1.0 },
    silver: { min: 1000, max: 1499, name: 'Prata', multiplier: 1.5 },
    gold: { min: 1500, max: 1999, name: 'Ouro', multiplier: 2.0 },
    platinum: { min: 2000, max: 2499, name: 'Platina', multiplier: 3.0 },
    diamond: { min: 2500, max: Float::INFINITY, name: 'Diamante', multiplier: 4.0 }
  }.freeze

  def self.calculate_expected_score(rating_a, rating_b)
    1.0 / (1.0 + 10**((rating_b - rating_a) / 400.0))
  end

  def self.calculate_elo_change(team, opponent_team, result)
    k_factor = determine_k_factor(team)
    expected = calculate_expected_score(team.elo_rating, opponent_team.elo_rating)

    actual_score = case result
    when :win then 1.0
    when :draw then 0.5
    when :loss then 0.0
    end

    change = (k_factor * (actual_score - expected)).round
    change
  end

  def self.update_ratings(team1, team2, match_result)
    initial_team1_elo = team1.elo_rating
    initial_team2_elo = team2.elo_rating

    if match_result[:winner] == team1
      team1_result = :win
      team2_result = :loss
    elsif match_result[:winner] == team2
      team1_result = :loss
      team2_result = :win
    else
      team1_result = :draw
      team2_result = :draw
    end

    team1_change = calculate_elo_change(team1, team2, team1_result)
    team2_change = calculate_elo_change(team2, team1, team2_result)

    # Atualizar ratings
    team1.elo_rating += team1_change
    team2.elo_rating += team2_change

    # Atualizar estatísticas
    update_team_stats(team1, team1_result)
    update_team_stats(team2, team2_result)

    # Atualizar highest_elo se necessário
    team1.highest_elo = [team1.highest_elo, team1.elo_rating].max
    team2.highest_elo = [team2.highest_elo, team2.elo_rating].max

    # Garantir que o ELO não fique negativo
    team1.elo_rating = [team1.elo_rating, 0].max
    team2.elo_rating = [team2.elo_rating, 0].max

    team1.save!
    team2.save!

    {
      team1_elo_before: initial_team1_elo,
      team2_elo_before: initial_team2_elo,
      team1_elo_change: team1_change,
      team2_elo_change: team2_change,
      team1_elo_after: team1.elo_rating,
      team2_elo_after: team2.elo_rating
    }
  end

  def self.get_division(elo_rating)
    DIVISIONS.each do |key, division|
      if elo_rating >= division[:min] && elo_rating <= division[:max]
        return { key: key, **division }
      end
    end
    DIVISIONS[:bronze]
  end

  def self.get_division_multiplier(elo_rating)
    division = get_division(elo_rating)
    division[:multiplier]
  end

  def self.matchmaking_range(elo_rating, search_time_seconds = 0)
    base_range = 100
    time_multiplier = 1 + (search_time_seconds / 30.0) # Aumenta 100% a cada 30 segundos
    max_range = 500

    current_range = (base_range * time_multiplier).round
    [current_range, max_range].min
  end

  private

  def self.determine_k_factor(team)
    total_matches = team.matches_won + team.matches_lost + team.matches_drawn

    if total_matches < 30
      K_FACTOR_NEW
    elsif total_matches < 100
      K_FACTOR_MID
    else
      K_FACTOR_PRO
    end
  end

  def self.update_team_stats(team, result)
    case result
    when :win
      team.matches_won += 1
    when :loss
      team.matches_lost += 1
    when :draw
      team.matches_drawn += 1
    end
  end
end