class ExpireInProgressPhoneCalls < ApplicationWorkflow
  attr_reader :session_limiters

  def initialize(**options)
    super()
    @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new ] }
  end

  def call
    stale_heartbeat = PhoneCall.in_progress.where(last_heartbeat_at: ..15.minute.ago)
    no_heartbeat = PhoneCall.in_progress.where(initiated_at: ..1.hours.ago, last_heartbeat_at: nil)

    expire_phone_calls(stale_heartbeat)
    expire_phone_calls(no_heartbeat)
  end

  private

  def expire_phone_calls(scope)
    phone_call_ids = []

    # Query optimization
    scope.find_each(cursor: :sequence_number, order: :desc) do |phone_call|
      phone_call_ids << phone_call.id
      session_limiters.each { _1.remove_session_from(phone_call.region.alias, scope: phone_call.account_id) }
    end

    PhoneCall.where(id: phone_call_ids).update_all(status: :session_timeout)
  end
end
