class RemoveDefautFromWallet < ActiveRecord::Migration[7.1]
  def change
    change_column_default :wallets, :balance, nil
  end
end
