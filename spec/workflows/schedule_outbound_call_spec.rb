require "rails_helper"

RSpec.describe ScheduleOutboundCall do
  it "does schedules an outbound call" do
    account = create(:account, calls_per_second: 2)
    _existing_queued_phone_calls = create_list(:phone_call, 3, :outbound, :queued, account:)
    phone_call = create(:phone_call, :outbound, :queued, account:)

    travel_to(Time.zone.local(2022, 1, 1, 1, 0, 0)) do
      ScheduleOutboundCall.call(phone_call)

      expect(ScheduledJob).to have_been_enqueued.with(
        OutboundCallJob.to_s,
        phone_call,
        wait_until: Time.zone.local(2022, 1, 1, 1, 0, 2) # delay 4 / 2 = 2 seconds
      )
    end
  end
end
