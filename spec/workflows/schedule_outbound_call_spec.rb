require "rails_helper"

RSpec.describe ScheduleOutboundCall do
  it "schedules an outbound call" do
    account = create(:account)
    phone_call = create(:phone_call, account:)
    queue = OutboundCallsQueue.new(account)

    ScheduleOutboundCall.call(phone_call, queue:)

    expect(queue.peek).to eq(phone_call.id)
    expect(OutboundCallJob).to have_been_enqueued.with(account)
  end
end
