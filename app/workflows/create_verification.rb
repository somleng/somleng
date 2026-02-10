class CreateVerification < ApplicationWorkflow
  class Error < StandardError; end

  attr_reader :params

  def initialize(params)
    super()
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
    verification.update!(params.slice(:channel, :locale))
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
    elsif delivery_attempt.channel.call?
      phone_call = create_phone_call!(delivery_attempt)
      delivery_attempt.update!(phone_call:)
    end
  end

  def create_message!(delivery_attempt)
    schema = build_message_schema(delivery_attempt)
    check_schema!(schema)

    CreateMessage.call(schema.output.merge(direction: :outbound, internal: true))
  end

  def build_message_schema(delivery_attempt)
    TwilioAPI::MessageRequestSchema.new(
      input_params: {
        From: delivery_attempt.from.to_s,
        To: delivery_attempt.to.to_s,
        Body: delivery_attempt.verification.default_template.render_message
      },
      options: {
        account: delivery_attempt.verification.account,
        sender: delivery_attempt.from
      }
    )
  end

  def create_phone_call!(delivery_attempt)
    schema = build_phone_call_schema(delivery_attempt)
    check_schema!(schema)

    CreatePhoneCall.call(schema.output.merge(internal: true))
  end

  def build_phone_call_schema(delivery_attempt)
    TwilioAPI::PhoneCallRequestSchema.new(
      input_params: {
        From: delivery_attempt.from.to_s,
        To: delivery_attempt.to.to_s,
        Twiml: delivery_attempt.verification.default_template.render_voice_twiml
      },
      options: {
        account: delivery_attempt.verification.account,
        sender: delivery_attempt.from
      }
    )
  end

  def check_schema!(schema)
    raise(Error, schema.errors(full: true).map(&:text).to_sentence) unless schema.success?
  end
end
