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
    if delivery_attempt.channel.sms?
      message = create_message!(delivery_attempt)
      delivery_attempt.update!(message:)
      OutboundMessageJob.perform_later(message)
    elsif delivery_attempt.channel.call?
      phone_call = create_phone_call!(delivery_attempt)
      delivery_attempt.update!(phone_call:)
      ScheduleOutboundCall.call(phone_call)
    end
  end

  def create_message!(delivery_attempt)
    schema = build_message_schema(delivery_attempt)
    check_schema!(schema)

    Message.create!(schema.output.merge(direction: :outbound, internal: true))
  end

  def build_message_schema(delivery_attempt)
    TwilioAPI::MessageRequestSchema.new(
      input_params: {
        From: delivery_attempt.from,
        To: delivery_attempt.to,
        Body: delivery_attempt.verification.default_template.render_message
      },
      options: {
        account: delivery_attempt.verification.account
      }
    )
  end

  def create_phone_call!(delivery_attempt)
    schema = build_phone_call_schema(delivery_attempt)
    check_schema!(schema)

    PhoneCall.create!(schema.output.merge(internal: true))
  end

  def build_phone_call_schema(delivery_attempt)
    TwilioAPI::PhoneCallRequestSchema.new(
      input_params: {
        From: delivery_attempt.from,
        To: delivery_attempt.to,
        Twiml: delivery_attempt.verification.default_template.render_voice_twiml
      },
      options: {
        account: delivery_attempt.verification.account
      }
    )
  end

  def check_schema!(schema)
    return if schema.success?

    raise(Error, schema.errors(full: true).map(&:text).to_sentence)
  end
end
