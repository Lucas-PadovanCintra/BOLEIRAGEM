class WalletsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wallet


  def financial_report
    # Filtros de período
    @period = params[:period] || 'all'
    @category = params[:category]
    @type = params[:type]

    # Base query
    @transactions = @wallet.transactions

    # Aplicar filtros de período
    case @period
    when 'today'
      @transactions = @transactions.today
      @period_label = 'Hoje'
    when 'week'
      @transactions = @transactions.this_week
      @period_label = 'Esta Semana'
    when 'month'
      @transactions = @transactions.this_month
      @period_label = 'Este Mês'
    else
      @period_label = 'Todos os Períodos'
    end

    # Aplicar outros filtros
    @transactions = @transactions.by_category(@category) if @category.present?
    @transactions = @transactions.by_type(@type) if @type.present?

    # Paginação - usando will_paginate ao invés de kaminari
    @transactions = @transactions.recent.includes(:match, :team, :player).paginate(page: params[:page], per_page: 20)

    # Estatísticas do período
    base_transactions = @wallet.transactions
    base_transactions = base_transactions.today if @period == 'today'
    base_transactions = base_transactions.this_week if @period == 'week'
    base_transactions = base_transactions.this_month if @period == 'month'

    @stats = {
      total_income: base_transactions.income.sum(:amount),
      total_expense: base_transactions.expense.sum(:amount).abs,
      net_result: base_transactions.sum(:amount),
      transaction_count: base_transactions.count,
      avg_income: base_transactions.income.average(:amount) || 0,
      avg_expense: (base_transactions.expense.average(:amount) || 0).abs
    }

    # Dados para gráficos
    @chart_data = prepare_chart_data(base_transactions)

    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(@transactions), filename: "relatorio_financeiro_#{Date.current}.csv" }
    end
  end

  def update
    if @wallet.update(wallet_params)
      redirect_to @wallet, notice: 'Wallet was successfully updated.'
    else
      render :show
    end
  end

  private

  def set_wallet
    if current_user.wallet.nil?
      new_wallet = Wallet.create!(user_id: current_user.id, balance: 1000)

      # Registrar transação inicial
      new_wallet.transactions.create!(
        amount: 1000,
        transaction_type: 'initial_balance',
        category: 'admin',
        description: 'Saldo inicial',
        balance_after: 1000
      )

      @wallet = new_wallet
    else
      @wallet = current_user.wallet
    end
  end

  def wallet_params
    params.require(:wallet).permit(:balance)
  end

  def prepare_chart_data(transactions)
    # Dados por categoria
    category_data = transactions.group(:category).sum(:amount).map do |category, amount|
      { category: Transaction.new(category: category).category_label, amount: amount.abs }
    end

    # Evolução do saldo (últimos 30 dias)
    dates = (30.days.ago.to_date..Date.current).to_a
    balance_evolution = []
    current_balance = @wallet.balance - transactions.where('created_at >= ?', 30.days.ago).sum(:amount)

    dates.each do |date|
      day_transactions = transactions.where(created_at: date.beginning_of_day..date.end_of_day).sum(:amount)
      current_balance += day_transactions
      balance_evolution << { date: date.strftime('%d/%m'), balance: current_balance }
    end

    {
      categories: category_data,
      balance_evolution: balance_evolution
    }
  end

  def generate_csv(transactions)
    require 'csv'

    CSV.generate(headers: true) do |csv|
      csv << ['Data', 'Tipo', 'Categoria', 'Descrição', 'Valor', 'Saldo Após']

      transactions.each do |t|
        csv << [
          t.created_at.strftime('%d/%m/%Y %H:%M'),
          t.type_label,
          t.category_label,
          t.description,
          t.formatted_amount,
          t.balance_after
        ]
      end
    end
  end
end
