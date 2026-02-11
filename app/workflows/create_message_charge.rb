class CreateMessageCharge < ApplicationWorkflow
  class Error < StandardError
    attr_reader :record

    def initialize(message, record:)
      super(message)
      @record = record
    end
  end

  class CreditValidator
    def sufficient_balance?(...)
      true
    end
  end

  attr_reader :message, :client, :account_billing_policy

  def initialize(message, **options)
    super()
    @message = message
    @client = options.fetch(:client) { RatingEngineClient.new }
    @account_billing_policy = options.fetch(:account_billing_policy) { AccountBillingPolicy.new(credit_validator: CreditValidator.new) }
  end

  def call
    return unless message.account.billing_enabled?

    validate_account_billing_policy!
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

  def validate_account_billing_policy!
    return if account_billing_policy.valid?(interaction: message)

    mark_as_failed(account_billing_policy.error_code)
    raise Error.new(account_billing_policy.error_code, record: message)
  end
end
