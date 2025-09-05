class ChangeRatingToFloatInPlayers < ActiveRecord::Migration[7.1]
  def change
    change_column :players, :rating, :float
  end
end
