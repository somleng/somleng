class DestroyAccount < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      result = resource.destroy
      client.destroy_account(resource) if result
      result
    end
  end
end
