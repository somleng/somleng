require "rails_helper"

RSpec.describe PerMinuteJob do
  it "enqueues jobs to be run per minute" do
    PerMinuteJob.perform_now

    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ProcessOutboundCallsQueue.to_s)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(PublishOutboundCallsQueueMetrics.to_s)
  end
end
