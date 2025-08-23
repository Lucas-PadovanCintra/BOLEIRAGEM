class CreatePlayerContracts < ActiveRecord::Migration[7.1]
  def change
    create_table :player_contracts do |t|
      t.references :player, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :matches_played, default: 0
      t.integer :contract_length, default: 5
      t.boolean :is_expired, default: false

      t.timestamps
    end

    add_index :player_contracts, :is_expired
  end
end
