class DestroyTariffSchedule < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      result = resource.destroy
      client.destroy_tariff_schedule(resource) if resource.destroyed?
      result
    end
  end
end
