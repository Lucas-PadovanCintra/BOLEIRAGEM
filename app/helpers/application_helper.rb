module ApplicationHelper
  def team_logo(real_team_name)
    return 'placeholder.png' if real_team_name.blank?

    team = ""
    extension = "png"
    case real_team_name
    when "Sport Recife"
      team = "sport"
      extension = "gif"
    when "Flamengo"
      team = "fla"
    when "Internacional"
      team = "interrs"
    when "São Paulo"
      team = "saopaulo"
    when "Atlético Mineiro"
      team = "atletico"
    when "Red Bull Bragantino"
      team = "bragantino"
    when "Botafogo"
      team = "botafogo"
      extension = "gif"
    when "Vasco da Gama"
      team = "vasco"
    else
      team = I18n.transliterate(real_team_name.downcase).gsub(/[^a-z0-9]+/, '-')
    end
    return "#{team}.#{extension}"
  end
end
