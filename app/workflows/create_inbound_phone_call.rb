class CreateInboundPhoneCall < ApplicationWorkflow
  attr_reader :params, :session_limiter

  def initialize(params, **options)
    super()
    @params = params
    @session_limiter = options.fetch(:session_limiter) { PhoneCallSessionLimiter.new }
  end

  def call
    phone_call = ApplicationRecord.transaction do
      phone_call = PhoneCall.create!(params)
      phone_call.initiating_at = Time.current
      phone_call.initiated_at = phone_call.initiating_at
      phone_call.mark_as_initiated!
      phone_call
    end

    session_limiter.add_session_to(phone_call.region.alias)

    phone_call
  end
end
