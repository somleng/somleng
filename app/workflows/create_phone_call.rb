class CreatePhoneCall < ApplicationWorkflow
  ATTRIBUTE_MAPPINGS = {
    To: :to,
    From: :from,
    Url: :voice_url,
    Method: :voice_method,
    StatusCallback: :status_callback_url,
    StatusCallbackMethod: :status_callback_method
  }.freeze

  def call
    phone_call = create_phone_call
    enqueue_outbound_call(phone_call)
    phone_call
  end

  private

  def create_phone_call
    phone_call = PhoneCall.new(options.fetch(:attributes).transform_keys { |k| ATTRIBUTE_MAPPINGS.fetch(k) })
    phone_call.account = options.fetch(:account)
    phone_call.save!
    phone_call
  end

  def enqueue_outbound_call(phone_call)
    ExecuteWorkflowJob.perform_later(InitiateOutboundCall.to_s, phone_call: phone_call)
  end
end
