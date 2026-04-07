class ExpireInProgressPhoneCalls < ApplicationWorkflow
  attr_reader :session_limiters

  def initialize(**options)
    super()
    @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new ] }
  end

  def call
    expired_phone_calls.find_each do |phone_call|
      phone_call.update_columns(status: :session_timeout)
      session_limiters.each { _1.remove_session_from(phone_call.region.alias, scope: phone_call.account_id) }
    end
  end

  private

  def expired_phone_calls
    stale_heartbeat = PhoneCall.where(last_heartbeat_at: ..1.minute.ago)
    no_heartbeat_too_long = PhoneCall.where(initiated_at: ..1.hours.ago, last_heartbeat_at: nil)

    PhoneCall.in_progress.merge(stale_heartbeat.or(no_heartbeat_too_long))
  end
end
