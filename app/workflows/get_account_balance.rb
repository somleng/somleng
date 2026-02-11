class GetAccountBalance < ApplicationWorkflow
  attr_reader :account, :client

  def initialize(account, **options)
    super()
    @account = account
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    client.account_balance(account)
  end
end
