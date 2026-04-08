class ExpireInProgressPhoneCalls < ApplicationWorkflow
  attr_reader :session_limiters

  def initialize(**options)
    super()
    @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new ] }
  end

  def call
    phone_call_ids = []

    expired_phone_calls.find_each do |phone_call|
      phone_call_ids << phone_call.id
      session_limiters.each { _1.remove_session_from(phone_call.region.alias, scope: phone_call.account_id) }
    end

    PhoneCall.where(id: phone_call_ids).update_all(status: :session_timeout)
  end

  private

  def expired_phone_calls
    stale_heartbeat = PhoneCall.where(last_heartbeat_at: ..2.minute.ago)
    no_heartbeat = PhoneCall.where(initiated_at: ..1.hours.ago, last_heartbeat_at: nil)

    PhoneCall.in_progress.merge(stale_heartbeat.or(no_heartbeat))
  end
end
