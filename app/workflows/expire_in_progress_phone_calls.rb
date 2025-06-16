class ExpireInProgressPhoneCalls < ApplicationWorkflow
  attr_reader :session_limiters

  def initialize(**options)
    super()
    @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new, GlobalCallSessionLimiter.new ] }
  end

  def call
    PhoneCall.in_progress.where(initiated_at: ..4.hours.ago).find_each do |phone_call|
      phone_call.update_columns(status: :session_timeout)
      session_limiters.each { _1.remove_session_from(phone_call.region.alias, scope: phone_call.account_id) }
    end
  end
end
