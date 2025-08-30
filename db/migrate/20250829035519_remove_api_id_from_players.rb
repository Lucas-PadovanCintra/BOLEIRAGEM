class RemoveApiIdFromPlayers < ActiveRecord::Migration[7.1]
  def change
    remove_column :players, :api_id, :integer
  end
end
