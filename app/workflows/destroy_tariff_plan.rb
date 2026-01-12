class DestroyTariffPlan < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      client.destroy_tariff_plan(resource) if resource.destroy
    end
  end
end
