class CreateInboundPhoneCall < ApplicationWorkflow
  attr_reader :params, :session_limiters

  def initialize(params, **options)
    super()
    @params = params
    @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new ] }
  end

  def call
    phone_call = ApplicationRecord.transaction do
      phone_call = PhoneCall.create!(params)
      phone_call.initiating_at = Time.current
      phone_call.initiated_at = phone_call.initiating_at
      phone_call.mark_as_initiated!
      phone_call
    end

    session_limit(phone_call)

    phone_call
  end

  private

  def session_limit(phone_call)
    session_limiters.each { _1.add_session_to(phone_call.region.alias, scope: phone_call.account_id) }
  end
end
