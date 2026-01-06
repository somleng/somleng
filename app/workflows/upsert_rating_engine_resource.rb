class UpsertRatingEngineResource < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, remote_action:, **options)
    super()
    @resource = resource
    @remote_action = remote_action
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      resource.save!
      remote_action.call(client, resource)
    end
  end
end
