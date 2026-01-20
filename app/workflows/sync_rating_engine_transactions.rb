class SyncRatingEngineTransactions < ApplicationWorkflow
  attr_reader :client, :batch_size

  def initialize(**options)
    super()
    @client = options.fetch(:client) { RatingEngineClient.new }
    @batch_size = options.fetch(:batch_size) { 1000 }
  end

  def call
    last_id = BalanceTransaction.where.not(external_id: nil).order(external_id: :desc).pick(:external_id)

    loop do
      records = client.fetch_cdrs(last_id:, limit: batch_size)
      records.each do |cdr|
        if cdr.balance_transaction_id.present?
          BalanceTransaction.where(id: cdr.balance_transaction_id).update_all(external_id: cdr.id)
          next
        end

        account = Account.find(cdr.account_id)
        amount = Money.from_amount(cdr.cost, account.billing_currency)

        next unless amount.positive?

        BalanceTransaction.create_or_find_by!(external_id: cdr.id) do |balance_transaction|
          balance_transaction.account = account
          balance_transaction.carrier_id = account.carrier_id
          balance_transaction.type = :charge
          balance_transaction.amount = -amount
        end
      end

      break if records.length < batch_size
      last_id = records.last.id
    end
  end
end
