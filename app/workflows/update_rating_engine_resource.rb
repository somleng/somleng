class UpdateRatingEngineResource < ApplicationWorkflow
  attr_reader :resource, :action, :client

  def initialize(resource, action:, **options)
    super()
    @resource = resource
    @action = action
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      resource.save
      action.call(resource, client) if resource.persisted?
      resource
    end
  end
end
