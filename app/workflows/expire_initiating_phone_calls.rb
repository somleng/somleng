class ExpireInitiatingPhoneCalls < ApplicationWorkflow
  def call
    PhoneCall.initiating.where(initiating_at: ..12.hours.ago).update_all(status: :canceled)
  end
end
