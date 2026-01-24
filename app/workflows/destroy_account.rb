class DestroyAccount < ApplicationWorkflow
  attr_reader :account, :client

  def initialize(account, **options)
    super()
    @account = account
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    destroy_account
  end

  private

  def destroy_account
    ApplicationRecord.transaction do
      account.destroy!
      client.destroy_account(account)
      account.destroyed?
    end
  rescue ActiveRecord::RecordNotDestroyed
    false
  end
end
