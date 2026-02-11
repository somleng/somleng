class CreateAccount < ApplicationWorkflow
  attr_reader :params, :client

  def initialize(params, **options)
    super()
    @params = params
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      account = Account.create!(params)
      client.upsert_account(account)
      account
    end
  end
end
