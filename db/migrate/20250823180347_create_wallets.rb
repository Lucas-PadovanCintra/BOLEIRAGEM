class CreateWallets < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :balance, default: 1000

      t.timestamps
    end
  end
end
