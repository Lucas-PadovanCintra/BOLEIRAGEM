class MatchNotification < ApplicationRecord
  belongs_to :user
  belongs_to :match

  validates :viewed, inclusion: { in: [true, false] }

  scope :unviewed, -> { where(viewed: false) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_viewed!
    update!(viewed: true)
  end

  def generate_message
    return message if message.present?
    
    if match.draw?
      "Sua partida terminou empatada! #{match.team1.name} #{match.team1_score} x #{match.team2_score} #{match.team2.name}"
    elsif match.winner_team.user_id == user_id
      "Parabéns! Seu time #{match.winner_team.name} venceu! #{match.team1.name} #{match.team1_score} x #{match.team2_score} #{match.team2.name}"
    else
      "Seu time perdeu a partida. #{match.team1.name} #{match.team1_score} x #{match.team2_score} #{match.team2.name}"
    end
  end
end