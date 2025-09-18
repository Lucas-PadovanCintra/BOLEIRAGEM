class MatchSimulator
  def initialize(team1, team2)
    @team1 = team1
    @team2 = team2
  end

  def simulate
    team1_strength = calculate_team_strength(@team1)
    team2_strength = calculate_team_strength(@team2)

    # Aplicar ajuste baseado em ELO
    elo_adjustment = calculate_elo_adjustment(@team1, @team2)
    team1_strength *= (1 + elo_adjustment[:team1_modifier])
    team2_strength *= (1 + elo_adjustment[:team2_modifier])

    team1_final_strength = team1_strength * random_factor
    team2_final_strength = team2_strength * random_factor

    scores = calculate_scores(team1_final_strength, team2_final_strength)

    winner = determine_winner(scores[:team1_score], scores[:team2_score])

    {
      team1_score: scores[:team1_score],
      team2_score: scores[:team2_score],
      winner: winner,
      status: calculate_status(scores[:team1_score], scores[:team2_score]),
      stats: {
        team1_strength: team1_strength.round(2),
        team2_strength: team2_strength.round(2),
        team1_final_strength: team1_final_strength.round(2),
        team2_final_strength: team2_final_strength.round(2),
        team1_attack: calculate_attack_power(@team1).round(2),
        team2_attack: calculate_attack_power(@team2).round(2),
        team1_defense: calculate_defense_power(@team1).round(2),
        team2_defense: calculate_defense_power(@team2).round(2),
        team1_midfield: calculate_midfield_control(@team1).round(2),
        team2_midfield: calculate_midfield_control(@team2).round(2),
        team1_elo: @team1.elo_rating,
        team2_elo: @team2.elo_rating,
        elo_adjustment: elo_adjustment
      }
    }
  end

  private

  def calculate_team_strength(team)
    players = team.players.includes(:player_contracts).where(player_contracts: { is_expired: false })

    return 50.0 if players.empty?

    attack_power = calculate_attack_power(team)
    defense_power = calculate_defense_power(team)
    midfield_control = calculate_midfield_control(team)

    (attack_power * 0.4) + (defense_power * 0.3) + (midfield_control * 0.3)
  end

  def calculate_attack_power(team)
    attackers = team.players.where(position: ['atacante', 'meia'])
    return 40.0 if attackers.empty?

    attackers.average(
      "(COALESCE(goals, 0) * 2.0 + COALESCE(assists, 0) * 1.5 + COALESCE(successful_dribbles, 0) * 0.5)"
    ) || 40.0
  end

  def calculate_defense_power(team)
    defenders = team.players.where(position: ['goleiro', 'zagueiro', 'lateral-direito', 'lateral-esquerdo'])
    return 40.0 if defenders.empty?

    defenders.average(
      "(COALESCE(interceptions, 0) * 2.0 + (100 - COALESCE(loss_of_possession, 50)) * 0.3 + COALESCE(rating, 50) * 0.2)"
    ) || 40.0
  end

  def calculate_midfield_control(team)
    midfielders = team.players.where(position: ['volante', 'meia'])
    return 40.0 if midfielders.empty?

    midfielders.average(
      "(COALESCE(frequency_in_field, 50) * 0.5 + COALESCE(rating, 50) * 0.5)"
    ) || 40.0
  end

  def random_factor
    0.9 + (rand * 0.2)
  end

  def calculate_scores(team1_strength, team2_strength)
    strength_difference = team1_strength - team2_strength
    base_goals = 2

    team1_goals_potential = base_goals + (strength_difference / 20.0)
    team2_goals_potential = base_goals - (strength_difference / 20.0)

    team1_score = [0, (team1_goals_potential + rand(-1.0..1.0)).round].max
    team2_score = [0, (team2_goals_potential + rand(-1.0..1.0)).round].max

    {
      team1_score: team1_score,
      team2_score: team2_score
    }
  end

  def calculate_status(team1_score, team2_score)
    if team1_score > team2_score
      'win'
    elsif team2_score > team1_score
      'loss'
    else
      'draw'
    end

  end

  def determine_winner(team1_score, team2_score)
    if team1_score > team2_score
      @team1
    elsif team2_score > team1_score
      @team2
    else
      nil
    end
  end

  def calculate_elo_adjustment(team1, team2)
    # Calcular ajuste baseado na diferença de ELO
    # Times com maior ELO têm pequena vantagem, mas não determinante
    elo_diff = team1.elo_rating - team2.elo_rating
    max_adjustment = 0.15 # Máximo de 15% de ajuste

    # Suavizar a diferença para não ser muito drástica
    adjustment_factor = Math.tanh(elo_diff / 500.0) * max_adjustment

    {
      team1_modifier: adjustment_factor,
      team2_modifier: -adjustment_factor,
      elo_difference: elo_diff
    }
  end
end
