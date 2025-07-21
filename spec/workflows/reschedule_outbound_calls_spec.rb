require "rails_helper"

RSpec.describe RescheduleOutboundCalls do
  it "schedules outbound calls" do
    phone_calls = create_list(:phone_call, 2, :queued, created_at: 31.minutes.ago)
    create(:phone_call, :queued)

    RescheduleOutboundCalls.call

    expect(ExecuteWorkflowJob).to have_been_enqueued.exactly(2).times
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ScheduleOutboundCall.to_s, phone_calls[0]).exactly(1).times
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ScheduleOutboundCall.to_s, phone_calls[1]).exactly(1).times
  end
end
