class ExpireInProgressPhoneCalls < ApplicationWorkflow
  def call
    PhoneCall.in_progress.where(initiated_at: ..4.hours.ago).update_all(status: :session_timeout)
  end
end
