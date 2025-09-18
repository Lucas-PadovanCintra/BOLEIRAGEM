class MatchmakingService
  def self.add_to_queue(team, user)
    return { error: "Time já está na fila" } if team.in_matchmaking_queue?
    return { error: "Time precisa ter pelo menos um jogador com contrato ativo" } if team.active_players.count == 0

    ActiveRecord::Base.transaction do
      queue_entry = TeamMatchmakingQueue.create!(
        team: team,
        user: user,
        status: 'waiting'
      )

      opponent = find_opponent(queue_entry)
      
      if opponent
        match = create_and_simulate_match(queue_entry, opponent)
        { success: true, match: match, matched: true }
      else
        { success: true, queue_entry: queue_entry, matched: false }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    { error: e.message }
  end

  def self.remove_from_queue(team)
    queue_entry = team.current_queue_entry
    return { error: "Time não está na fila" } unless queue_entry

    queue_entry.update!(status: 'cancelled')
    { success: true }
  end

  private

  def self.find_opponent(queue_entry)
    team = queue_entry.team
    search_start_time = queue_entry.created_at
    time_waiting = Time.current - search_start_time

    # Calcular range de ELO baseado no tempo de espera
    elo_range = EloService.matchmaking_range(team.elo_rating, time_waiting.to_i)

    # Buscar oponente dentro do range de ELO
    potential_opponents = TeamMatchmakingQueue
      .waiting
      .not_from_team(queue_entry.team_id)
      .where.not(user_id: queue_entry.user_id)
      .joins(:team)
      .where(teams: { elo_rating: (team.elo_rating - elo_range)..(team.elo_rating + elo_range) })
      .order(Arel.sql("ABS(teams.elo_rating - #{team.elo_rating})"))

    opponent = potential_opponents.first

    # Se não encontrar dentro do range, expandir busca gradualmente
    if opponent.nil? && time_waiting > 60
      Rails.logger.info "Expanding search for team #{team.name} (ELO: #{team.elo_rating}) - no opponents in ±#{elo_range} range"

      # Buscar qualquer oponente disponível
      opponent = TeamMatchmakingQueue
        .waiting
        .not_from_team(queue_entry.team_id)
        .where.not(user_id: queue_entry.user_id)
        .oldest_first
        .first
    end

    if opponent
      Rails.logger.info "Match found: #{team.name} (#{team.elo_rating}) vs #{opponent.team.name} (#{opponent.team.elo_rating})"
    end

    opponent
  end

  def self.create_and_simulate_match(queue_entry1, queue_entry2)
    team1 = queue_entry1.team
    team2 = queue_entry2.team

    # Armazenar ELO antes da partida
    team1_elo_before = team1.elo_rating
    team2_elo_before = team2.elo_rating

    match = Match.create!
    match.match_teams.create!(team: team1, is_team1: true)
    match.match_teams.create!(team: team2, is_team1: false)

    simulator = MatchSimulator.new(team1, team2)
    result = simulator.simulate

    # Processar mudanças de ELO
    elo_changes = EloService.update_ratings(team1, team2, result)

    # Processar recompensas
    reward_amount = RewardService.process_match_rewards(match, team1, team2, result)

    match.update!(
      team1_score: result[:team1_score],
      team2_score: result[:team2_score],
      winner_team: result[:winner],
      is_simulated: true,
      simulation_stats: result[:stats],
      team1_elo_before: team1_elo_before,
      team2_elo_before: team2_elo_before,
      team1_elo_change: elo_changes[:team1_elo_change],
      team2_elo_change: elo_changes[:team2_elo_change],
      reward_amount: reward_amount
    )

    queue_entry1.update!(status: 'matched', matched_at: Time.current, match: match)
    queue_entry2.update!(status: 'matched', matched_at: Time.current, match: match)

    handle_post_match_logic(team1, team2)

    create_notifications(match, team1, team2)

    match
  end

  def self.handle_post_match_logic(team1, team2)
    [team1, team2].each do |team|
      team.player_contracts.where(is_expired: false).each do |contract|
        contract.increment!(:matches_played)
        if contract.matches_played >= contract.contract_length
          contract.update!(is_expired: true)
          contract.player.update!(is_on_market: true)
          user_wallet = team.user.wallet
          user_wallet.update!(balance: user_wallet.balance + contract.player.price)
          PlayerCooldown.create!(player: contract.player, team: team, matches_remaining: 5)
        end
      end
      
      team.player_cooldowns.each do |cooldown|
        cooldown.decrement!(:matches_remaining)
      end
    end
  end

  def self.create_notifications(match, team1, team2)
    [team1, team2].each do |team|
      notification = MatchNotification.create!(
        user: team.user,
        match: match,
        viewed: false
      )
      
      notification.update!(message: notification.generate_message)
      Rails.logger.info "Created notification #{notification.id} for user #{team.user.email} - Match #{match.id}"
    end
  end
end