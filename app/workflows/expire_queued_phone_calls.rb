class ExpireQueuedPhoneCalls < ApplicationWorkflow
  def call
    PhoneCall.queued.where(created_at: ..7.days.ago).update_all(status: :canceled)
  end
end
