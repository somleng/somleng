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
        amount = InfinitePrecisionMoney.new(cdr.cost, account.billing_currency)

        next unless amount.positive?

        balance_transaction = BalanceTransaction.create_or_find_by!(external_id: cdr.id) do |record|
          record.account = account
          record.carrier_id = account.carrier_id
          record.type = :charge
          record.amount = -amount
          record.charge_category = cdr.category

          if record.charge_category.tariff_category.message?
            record.message = Message.find_by(id: cdr.origin_id)
          elseif record.charge_category.tariff_category.call?
            record.phone_call = PhoneCall.find_by(id: cdr.origin_id)
          else
            raise "Invalid charge category: #{record.charge_category}"
          end
        end

        if balance_transaction.message.present?
          balance_transaction.message.update!(
            price_cents: amount.cents,
            price_unit: amount.currency
          )
        end

        if balance_transaction.phone_call.present?
          balance_transaction.phone_call.update!(
            price_cents: amount.cents,
            price_unit: amount.currency
          )
        end
      end

      break if records.length < batch_size
      last_id = records.last.id
    end
  end
end
