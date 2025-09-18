namespace :players do
  desc "Recalculate all player prices based on new pricing formula"
  task recalculate_prices: :environment do
    puts "Starting player price recalculation..."

    updated_count = 0
    total_price_before = 0
    total_price_after = 0

    Player.find_each do |player|
      old_price = player.price
      new_price = RewardService.calculate_player_price(player)

      total_price_before += old_price
      total_price_after += new_price

      if old_price != new_price
        player.update!(price: new_price)
        updated_count += 1

        puts "#{player.name}: #{old_price} -> #{new_price} (#{new_price > old_price ? '+' : ''}#{new_price - old_price})"
      end
    end

    puts "\n" + "="*50
    puts "Price recalculation completed!"
    puts "Players updated: #{updated_count}/#{Player.count}"
    puts "Average price before: #{(total_price_before.to_f / Player.count).round(2)}"
    puts "Average price after: #{(total_price_after.to_f / Player.count).round(2)}"
    puts "Total price change: #{total_price_after - total_price_before}"
  end

  desc "Show price distribution by position"
  task price_distribution: :environment do
    puts "\nPrice distribution by position:"
    puts "="*50

    positions = Player.distinct.pluck(:position).compact.sort

    positions.each do |position|
      players = Player.where(position: position)
      avg_price = players.average(:price)&.round(2) || 0
      min_price = players.minimum(:price) || 0
      max_price = players.maximum(:price) || 0

      puts "#{position.capitalize.ljust(20)} Count: #{players.count.to_s.rjust(3)}, " \
           "Avg: #{avg_price.to_s.rjust(6)}, " \
           "Min: #{min_price.to_s.rjust(5)}, " \
           "Max: #{max_price.to_s.rjust(5)}"
    end
  end
end