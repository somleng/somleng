require "rails_helper"

RSpec.describe RescheduleOutboundCalls do
  it "schedules outbound calls" do
    phone_calls = create_list(:phone_call, 2, :queued, created_at: 31.minutes.ago)
    create(:phone_call, :queued, created_at: 31.minutes.ago, initiation_queued_at: Time.current)
    create(:phone_call, :queued)
    workflow = class_spy(ScheduleOutboundCall)

    RescheduleOutboundCalls.call(workflow:)

    expect(workflow).to have_received(:call).exactly(2).times
    expect(workflow).to have_received(:call).with(phone_calls[0]).exactly(1).times
    expect(workflow).to have_received(:call).with(phone_calls[1]).exactly(1).times
  end
end
