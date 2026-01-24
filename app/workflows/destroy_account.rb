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
      result = account.destroy!
      client.destroy_account(account)
      result
    end
  rescue ActiveRecord::RecordNotDestroyed
    account
  end
end
