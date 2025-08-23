class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.integer :api_id, null: false
      t.string :name, null: false
      t.integer :rating, null: false
      t.integer :price, null: false
      t.boolean :is_on_market, default: true

      t.timestamps
    end

    add_index :players, :api_id, unique: true
    add_index :players, :is_on_market
  end
end
