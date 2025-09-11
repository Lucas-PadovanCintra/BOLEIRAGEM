class CreateTeamMatchmakingQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :team_matchmaking_queues do |t|
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'waiting', null: false
      t.datetime :matched_at
      t.references :match, foreign_key: true

      t.timestamps
    end

    add_index :team_matchmaking_queues, :status
    add_index :team_matchmaking_queues, [:team_id, :status], unique: true, where: "status = 'waiting'"
  end
end
