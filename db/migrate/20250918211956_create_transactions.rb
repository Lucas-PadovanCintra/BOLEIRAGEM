class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :wallet, null: false, foreign_key: true
      t.integer :amount, null: false
      t.string :transaction_type, null: false
      t.text :description
      t.string :category, null: false
      t.references :match, foreign_key: true  # Optional - only for match-related transactions
      t.integer :balance_after  # Balance after this transaction
      t.references :team, foreign_key: true  # Optional - which team was involved
      t.references :player, foreign_key: true  # Optional - for player purchases/sales

      t.timestamps
    end

    # Add indexes for better query performance
    add_index :transactions, :transaction_type
    add_index :transactions, :category
    add_index :transactions, [:wallet_id, :created_at]
  end
end
