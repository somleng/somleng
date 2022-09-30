require "rails_helper"

RSpec.describe HourlyJob do
  it "enqueues jobs to be run daily" do
    HourlyJob.perform_now

    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ExpireInProgressPhoneCalls.to_s)
  end
end
