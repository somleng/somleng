class CreateVerification < ApplicationWorkflow
  class Error < StandardError; end

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    ApplicationRecord.transaction do
      verification = create_or_update_verification!
      delivery_attempt = create_delivery_attempt!(verification)
      attempt_delivery(delivery_attempt)
      verification
    end
  end

  private

  def create_or_update_verification!
    verification = params.fetch(:verification) do
      Verification.create!(params.except(:delivery_attempt))
    end
    verification.update!(params.slice(:channel))
    verification
  end

  def create_delivery_attempt!(verification)
    verification.delivery_attempts.create!(
      params.slice(:to, :channel).merge(params.fetch(:delivery_attempt))
    )
  end

  def attempt_delivery(delivery_attempt)
    return unless delivery_attempt.channel.sms?

    message = create_message!(delivery_attempt)
    delivery_attempt.update!(message:)
    OutboundMessageJob.perform_later(message)
  end

  def create_message!(delivery_attempt)
    schema = build_message_schema(delivery_attempt)

    raise(Error, schema.errors(full: true).map(&:text).to_sentence) unless schema.success?

    Message.create!(schema.output.merge(direction: :outbound, internal: true))
  end

  def build_message_schema(delivery_attempt)
    TwilioAPI::MessageRequestSchema.new(
      input_params: {
        From: delivery_attempt.from,
        To: delivery_attempt.to,
        Body: delivery_attempt.verification.default_template.render
      },
      options: {
        account: delivery_attempt.verification.account
      }
    )
  end
end
