module ApplicationHelper
  def team_logo(real_team_name)
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
      else
        team = real_team_name
    end
    return "#{team}.#{extension}"
  end
end
