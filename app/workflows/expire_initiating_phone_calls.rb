class ExpireInitiatingPhoneCalls < ApplicationWorkflow
  def call
    PhoneCall.initiating.where(initiating_at: ..1.day.ago).update_all(status: :canceled)
  end
end
