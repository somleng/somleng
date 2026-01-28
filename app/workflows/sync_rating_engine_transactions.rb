class SyncRatingEngineTransactions < ApplicationWorkflow
  CDR = Data.define(
    :id,
    :origin_id,
    :balance_transaction_id,
    :category,
    :account,
    :amount,
    :message,
    :phone_call
  )

  attr_reader :client, :batch_size, :cursor_start

  def initialize(**options)
    super()
    @client = options.fetch(:client) { RatingEngineClient.new }
    @batch_size = options.fetch(:batch_size) { 1000 }
    @cursor_start = options.fetch(:cursor_start) { BalanceTransaction.where.not(external_id: nil).order(external_id: :desc).pick(:external_id) }
  end

  def call
    cursor = cursor_start

    loop do
      records = client.fetch_cdrs(last_id: cursor, limit: batch_size)
      records.each do |record|
        next update_existing_balance_transaction(record) if record.balance_transaction_id.present?
        next unless record.success?

        cdr = parse_cdr(record)

        balance_transaction = create_balance_transaction(cdr)
        if balance_transaction.charge_source.present?
          UpdateBalanceTransactionChargeSource.call(balance_transaction)
        else
          handle_missing_charge_source(balance_transaction, cdr)
        end
      end

      break if records.length < batch_size
      cursor = records.last.id
    end
  end

  private

  def update_existing_balance_transaction(cdr)
    BalanceTransaction.where(id: cdr.balance_transaction_id).update_all(external_id: cdr.id)
  end

  def parse_cdr(cdr)
    account = Account.find(cdr.account_id)
    category = TariffScheduleCategoryType.new.cast(cdr.category)
    message = account.messages.find_by(id: cdr.origin_id) if category.tariff_category.message?
    phone_call = account.phone_calls.find_by(external_id: cdr.origin_id) if category.tariff_category.call?

    CDR.new(
      id: cdr.id,
      origin_id: cdr.origin_id,
      balance_transaction_id: cdr.balance_transaction_id,
      category:,
      account:,
      amount: InfinitePrecisionMoney.new(cdr.cost, account.billing_currency),
      message:,
      phone_call:
    )
  end

  def create_balance_transaction(cdr)
    BalanceTransaction.create_or_find_by!(external_id: cdr.id) do |balance_transaction|
      balance_transaction.account = cdr.account
      balance_transaction.carrier_id = cdr.account.carrier_id
      balance_transaction.type = :charge
      balance_transaction.amount_cents = -cdr.amount.cents
      balance_transaction.currency = cdr.amount.currency
      balance_transaction.charge_category = cdr.category.value
      balance_transaction.charge_source_id = cdr.origin_id
      balance_transaction.message = cdr.message
      balance_transaction.phone_call = cdr.phone_call
    end
  end

  def handle_missing_charge_source(balance_transaction, cdr)
    return unless charge_source_missing_from?(balance_transaction)

    ExecuteWorkflowJob.perform_later(
      ReconcileBalanceTransactionChargeSource.to_s,
      balance_transaction,
      charge_source_id: cdr.origin_id
    )
  end

  def charge_source_missing_from?(balance_transaction)
    return false unless balance_transaction.charge_category.tariff_category.call?

    balance_transaction.charge_source.blank?
  end
end
