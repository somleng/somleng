class UpdateAccountForm < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      client.upsert_account_tariff_plan_subscriptions(resource.object) if resource.save
    end
  end
end
