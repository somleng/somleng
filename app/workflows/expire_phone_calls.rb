class ExpirePhoneCalls < ApplicationWorkflow
  attr_reader :eventable, :type, :event

  def call
    PhoneCall.queued.where(created_at: ..7.days.ago).update_all(status: :canceled)
  end
end
