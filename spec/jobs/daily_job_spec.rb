require "rails_helper"

RSpec.describe DailyJob do
  it "enqueues jobs to be run daily" do
    DailyJob.perform_now

    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ExpireQueuedPhoneCalls.to_s)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(PublishInteractionData.to_s)
  end
end
