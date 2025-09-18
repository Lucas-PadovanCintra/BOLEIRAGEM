class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :match, optional: true
  belongs_to :team, optional: true
  belongs_to :player, optional: true

  # Transaction types
  TYPES = {
    match_reward: 'match_reward',
    match_penalty: 'match_penalty',
    player_purchase: 'player_purchase',
    player_sale: 'player_sale',
    contract_expire: 'contract_expire',
    initial_balance: 'initial_balance',
    admin_adjustment: 'admin_adjustment'
  }.freeze

  # Categories
  CATEGORIES = {
    match: 'match',
    player: 'player',
    admin: 'admin',
    bonus: 'bonus'
  }.freeze

  validates :amount, presence: true
  validates :transaction_type, presence: true, inclusion: { in: TYPES.values }
  validates :category, presence: true, inclusion: { in: CATEGORIES.values }
  validates :wallet, presence: true

  # Scopes
  scope :income, -> { where('amount > 0') }
  scope :expense, -> { where('amount < 0') }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_period, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(created_at: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :this_month, -> { where(created_at: Date.current.beginning_of_month..Date.current.end_of_month) }

  # Callbacks
  before_create :set_balance_after

  def income?
    amount.positive?
  end

  def expense?
    amount.negative?
  end

  def formatted_amount
    if income?
      "+#{amount.abs}"
    else
      "-#{amount.abs}"
    end
  end

  def type_label
    case transaction_type
    when 'match_reward' then 'Recompensa de Partida'
    when 'match_penalty' then 'Penalidade de Partida'
    when 'player_purchase' then 'Compra de Jogador'
    when 'player_sale' then 'Venda de Jogador'
    when 'contract_expire' then 'Contrato Expirado'
    when 'initial_balance' then 'Saldo Inicial'
    when 'admin_adjustment' then 'Ajuste Administrativo'
    else transaction_type.humanize
    end
  end

  def category_label
    case category
    when 'match' then 'Partida'
    when 'player' then 'Jogador'
    when 'admin' then 'Administrativo'
    when 'bonus' then 'Bônus'
    else category.humanize
    end
  end

  def icon
    case transaction_type
    when 'match_reward' then 'fa-trophy text-success'
    when 'match_penalty' then 'fa-times-circle text-danger'
    when 'player_purchase' then 'fa-user-plus text-warning'
    when 'player_sale' then 'fa-user-minus text-info'
    when 'contract_expire' then 'fa-clock text-secondary'
    when 'initial_balance' then 'fa-wallet text-primary'
    when 'admin_adjustment' then 'fa-cog text-dark'
    else 'fa-circle'
    end
  end

  private

  def set_balance_after
    self.balance_after = wallet.balance
  end
end