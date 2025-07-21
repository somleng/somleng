require "rails_helper"

RSpec.describe HourlyJob do
  it "enqueues jobs to be run hourly" do
    HourlyJob.perform_now

    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ExpireInProgressPhoneCalls.to_s)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ExpireInitiatingPhoneCalls.to_s)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(RevokeSIPTrunkPermissions.to_s)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(RescheduleOutboundCalls.to_s)
  end
end
