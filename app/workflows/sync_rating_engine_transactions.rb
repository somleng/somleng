class SyncRatingEngineTransactions < ApplicationWorkflow
  attr_reader :client, :batch_size, :cursor_start

  CDR = Data.define(
    :id,
    :origin_id,
    :balance_transaction_id,
    :category,
    :account,
    :amount,
    :message,
    :phone_call,
    :interaction
  )

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
        cdr = parse_cdr(record)

        next update_existing_balance_transaction(cdr) if cdr.balance_transaction_id.present?
        next unless cdr.amount.positive?

        ApplicationRecord.transaction do
          create_balance_transaction(cdr)
          update_interaction(cdr)
        end
      end

      break if records.length < batch_size
      cursor = records.last.id
    end
  end

  private

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
      phone_call:,
      interaction: message || phone_call
    )
  end

  def update_existing_balance_transaction(cdr)
    BalanceTransaction.where(id: cdr.balance_transaction_id).update_all(external_id: cdr.id)
  end

  def create_balance_transaction(cdr)
    BalanceTransaction.create_or_find_by!(external_id: cdr.id) do |balance_transaction|
      balance_transaction.account = cdr.account
      balance_transaction.carrier_id = cdr.account.carrier_id
      balance_transaction.type = :charge
      balance_transaction.amount_cents = -cdr.amount.cents
      balance_transaction.currency = cdr.amount.currency
      balance_transaction.charge_category = cdr.category.value
      balance_transaction.message = cdr.message
      balance_transaction.phone_call = cdr.phone_call
    end
  end

  def update_interaction(cdr)
    cdr.interaction&.update!(price_cents: cdr.amount.cents, price_unit: cdr.amount.currency)
  end
end
