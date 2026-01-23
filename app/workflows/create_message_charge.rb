class CreateMessageCharge < ApplicationWorkflow
  class Error < StandardError; end

  attr_reader :message, :client

  def initialize(message, **options)
    super()
    @message = message
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    client.create_message_charge(message)
  rescue RatingEngineClient::InsufficientBalanceError => e
    mark_as_failed(:insufficient_balance)
    raise Error.new(e.message)
  end

  private

  def mark_as_failed(error_code)
    error = ApplicationError::Errors.fetch(error_code)
    message.error_code = error.code
    message.error_message = error.message
    message.mark_as_failed!
  end
end
