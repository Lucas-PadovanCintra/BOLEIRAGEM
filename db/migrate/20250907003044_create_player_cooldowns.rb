class CreatePlayerCooldowns < ActiveRecord::Migration[7.1]
  def change
    create_table :player_cooldowns do |t|
      t.references :player, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :matches_remaining, null: false, default: 5
      t.index [:player_id, :team_id], unique: true

      t.timestamps
    end
  end
end
