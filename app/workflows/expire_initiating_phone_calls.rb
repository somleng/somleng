class ExpireInitiatingPhoneCalls < ApplicationWorkflow
  attr_reader :timeout_seconds

  def initialize(options = {})
    @timeout_seconds = options.fetch(:timeout_seconds) do
      ExponentialBackoff.new.max_total_delay.seconds
    end
  end

  def call
    PhoneCall.initiating.where(initiating_at: ..timeout_seconds.ago).update_all(status: :canceled)
  end
end
