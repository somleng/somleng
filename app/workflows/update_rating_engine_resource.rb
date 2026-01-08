class UpdateRatingEngineResource < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call(&block)
    ApplicationRecord.transaction do
      block.call if resource.save
    end
  end
end
