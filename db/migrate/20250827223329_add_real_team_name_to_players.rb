class AddRealTeamNameToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :real_team_name, :string
    add_index :players, :real_team_name
  end
end
