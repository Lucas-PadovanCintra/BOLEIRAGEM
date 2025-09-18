class Wallet < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: true

  def total_income
    transactions.income.sum(:amount)
  end

  def total_expense
    transactions.expense.sum(:amount).abs
  end

  def income_this_month
    transactions.this_month.income.sum(:amount)
  end

  def expense_this_month
    transactions.this_month.expense.sum(:amount).abs
  end

  def recent_transactions(limit = 10)
    transactions.recent.limit(limit)
  end
end
