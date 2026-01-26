class CreateMessageCharge < ApplicationWorkflow
  class Error < StandardError
    attr_reader :record

    def initialize(message, record:)
      super(message)
      @record = record
    end
  end

  attr_reader :message, :client

  def initialize(message, **options)
    super()
    @message = message
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    return unless message.account.billing_enabled?
    handle_missing_subscription unless subscription_exists?

    client.create_message_charge(message)
  rescue RatingEngineClient::FailedCDRError => e
    mark_as_failed(e.error_code)
    raise Error.new(e.message, record: message)
  end

  private

  def mark_as_failed(error_code)
    error = ApplicationError::Errors.fetch(error_code)
    message.error_code = error.code
    message.error_message = error.message
    message.mark_as_failed!
  end

  def subscription_exists?
    message.account.tariff_plan_subscriptions.exists?(category: message.tariff_category)
  end

  def handle_missing_subscription
    mark_as_failed(:subscription_disabled)
    raise Error.new("Missing tariff plan subscription", record: message)
  end
end
