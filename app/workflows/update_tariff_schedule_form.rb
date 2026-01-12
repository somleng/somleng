class UpdateTariffScheduleForm < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      client.upsert_tariff_schedule(resource.object) if resource.save
    end
  end
end
