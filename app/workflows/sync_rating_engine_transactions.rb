class SyncRatingEngineTransactions < ApplicationWorkflow
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

        ProcessRatingEngineCDRJob.perform_later(record.to_h)
      end

      break if records.length < batch_size
      cursor = records.last.id
    end
  end

  private

  def update_existing_balance_transaction(cdr)
    BalanceTransaction.where(id: cdr.balance_transaction_id).update_all(external_id: cdr.id)
  end
end
