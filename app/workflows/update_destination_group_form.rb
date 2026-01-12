class UpdateDestinationGroupForm < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      client.upsert_destination_group(resource.object) if resource.save
    end
  end
end
