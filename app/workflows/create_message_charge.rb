class CreateMessageCharge < ApplicationWorkflow
  class Error < StandardError; end

  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    client.create_message_charge(resource)
  rescue RatingEngineClient::InsufficientBalanceError
    mark_as_failed(:insufficient_balance)
    raise Error
  end

  private

  def mark_as_failed(error_code)
    error = ApplicationError::Errors.fetch(error_code)
    resource.error_code = error.code
    resource.error_message = error.message
    resource.mark_as_failed!
  end
end
