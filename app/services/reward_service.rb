class RewardService
  BASE_REWARD = 50
  GOAL_DIFFERENCE_BONUS = 20    # Porcentagem de bônus por goleada
  UNDERDOG_BONUS_MULTIPLIER = 1.5  # Multiplicador quando azarão vence
  DRAW_REWARD_PERCENTAGE = 0.3     # 30% da recompensa base em empate

  def self.calculate_match_reward(winning_team, losing_team, match_stats)
    return 0 unless winning_team

    # Calcular recompensa base considerando diferença de ELO
    elo_difference = (losing_team.elo_rating - winning_team.elo_rating).abs
    base_amount = BASE_REWARD + (elo_difference / 10.0).round

    # Aplicar multiplicador da divisão
    division_multiplier = EloService.get_division_multiplier(winning_team.elo_rating)
    reward = base_amount * division_multiplier

    # Bônus por goleada (3+ gols de diferença)
    goal_difference = (match_stats[:team1_score] - match_stats[:team2_score]).abs
    if goal_difference >= 3
      reward *= (1 + GOAL_DIFFERENCE_BONUS / 100.0)
    end

    # Bônus para azarão (time com ELO menor que vence)
    if winning_team.elo_rating < losing_team.elo_rating && elo_difference > 200
      reward *= UNDERDOG_BONUS_MULTIPLIER
    end

    # Limitar recompensa máxima baseada na divisão
    max_reward = calculate_max_reward(winning_team.elo_rating)
    reward = [reward, max_reward].min

    reward.round
  end

  def self.calculate_draw_reward(team1, team2)
    avg_elo = (team1.elo_rating + team2.elo_rating) / 2.0
    base_amount = BASE_REWARD * DRAW_REWARD_PERCENTAGE

    division_multiplier = EloService.get_division_multiplier(avg_elo)
    reward = base_amount * division_multiplier

    reward.round
  end

  def self.calculate_loss_penalty(team)
    # Penalidade pequena por derrota, proporcional à divisão
    # Times de divisões mais altas pagam menos penalidade
    division = EloService.get_division(team.elo_rating)

    base_penalty = case division[:key]
    when :bronze then 20
    when :silver then 15
    when :gold then 10
    when :platinum then 5
    when :diamond then 0
    else 20
    end

    base_penalty
  end

  def self.process_match_rewards(match, team1, team2, match_result)
    reward_amount = 0
    team1_wallet = team1.user.wallet
    team2_wallet = team2.user.wallet

    if match_result[:winner]
      winning_team = match_result[:winner]
      losing_team = (winning_team == team1) ? team2 : team1
      winning_wallet = winning_team.user.wallet
      losing_wallet = losing_team.user.wallet

      # Calcular e aplicar recompensa para vencedor
      reward_amount = calculate_match_reward(
        winning_team,
        losing_team,
        {
          team1_score: match_result[:team1_score],
          team2_score: match_result[:team2_score]
        }
      )

      winning_wallet.update!(balance: winning_wallet.balance + reward_amount)

      # Registrar transação de recompensa
      winning_wallet.transactions.create!(
        amount: reward_amount,
        transaction_type: 'match_reward',
        category: 'match',
        description: "Vitória contra #{losing_team.name} (#{match_result[:team1_score]}x#{match_result[:team2_score]})",
        match: match,
        team: winning_team,
        balance_after: winning_wallet.balance
      )

      # Aplicar penalidade para perdedor (opcional)
      penalty = calculate_loss_penalty(losing_team)
      if penalty > 0
        new_balance = [losing_wallet.balance - penalty, 0].max
        losing_wallet.update!(balance: new_balance)

        # Registrar transação de penalidade
        losing_wallet.transactions.create!(
          amount: -penalty,
          transaction_type: 'match_penalty',
          category: 'match',
          description: "Derrota para #{winning_team.name} (#{match_result[:team1_score]}x#{match_result[:team2_score]})",
          match: match,
          team: losing_team,
          balance_after: losing_wallet.balance
        )
      end

      Rails.logger.info "Reward processed: Winner #{winning_team.name} received #{reward_amount}, Loser #{losing_team.name} lost #{penalty}"
    else
      # Empate - ambos recebem recompensa reduzida
      draw_reward = calculate_draw_reward(team1, team2)
      team1_wallet.update!(balance: team1_wallet.balance + draw_reward)
      team2_wallet.update!(balance: team2_wallet.balance + draw_reward)

      # Registrar transações de empate
      team1_wallet.transactions.create!(
        amount: draw_reward,
        transaction_type: 'match_reward',
        category: 'match',
        description: "Empate contra #{team2.name} (#{match_result[:team1_score]}x#{match_result[:team2_score]})",
        match: match,
        team: team1,
        balance_after: team1_wallet.balance
      )

      team2_wallet.transactions.create!(
        amount: draw_reward,
        transaction_type: 'match_reward',
        category: 'match',
        description: "Empate contra #{team1.name} (#{match_result[:team1_score]}x#{match_result[:team2_score]})",
        match: match,
        team: team2,
        balance_after: team2_wallet.balance
      )

      reward_amount = draw_reward

      Rails.logger.info "Draw reward: Both teams received #{draw_reward}"
    end

    reward_amount
  end

  def self.calculate_player_price(player)
    # Nova fórmula de precificação baseada em estatísticas
    base_price = (player.rating * 15).round

    # Adicionar valor por estatísticas ofensivas
    offensive_value = (player.goals.to_i * 5) + (player.assists.to_i * 3)

    # Adicionar valor por estatísticas defensivas
    defensive_value = (player.interceptions.to_i * 2) if player.position.in?(['zagueiro', 'lateral-direito', 'lateral-esquerdo', 'goleiro'])
    defensive_value ||= 0

    # Multiplicador por posição
    position_multiplier = case player.position
    when 'goleiro' then 0.8
    when 'zagueiro' then 0.9
    when 'lateral-direito', 'lateral-esquerdo' then 0.95
    when 'volante' then 1.0
    when 'meia' then 1.1
    when 'atacante' then 1.2
    else 1.0
    end

    # Penalidade por cartões e faltas
    discipline_penalty = (player.yellow_cards.to_i * 2) + (player.red_cards.to_i * 10) + (player.faults_committed.to_i * 0.5)

    # Calcular preço final
    final_price = ((base_price + offensive_value + defensive_value - discipline_penalty) * position_multiplier).round

    # Garantir preço mínimo
    [final_price, 50].max
  end

  private

  def self.calculate_max_reward(elo_rating)
    division = EloService.get_division(elo_rating)

    case division[:key]
    when :bronze then 200
    when :silver then 350
    when :gold then 500
    when :platinum then 750
    when :diamond then 1000
    else 200
    end
  end
end