require "rails_helper"

RSpec.describe "Events" do
  it "List events" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    phone_call = create(:phone_call, carrier:)
    event1 = create(:event, :phone_call_completed, phone_call:, carrier:)
    event2 = create(:event, :phone_call_completed, carrier:)
    event3 = create(:event)

    carrier_sign_in(user)
    visit dashboard_events_path(
      filter: {
        type: "phone_call.completed",
        phone_call_id: phone_call.id
      }
    )

    expect(page).to have_text(event1.id)
    expect(page).to have_no_text(event2.id)
    expect(page).to have_no_text(event3.id)
  end

  it "Show an event" do
    event = create(:event)
    user = create(:user, :carrier, carrier: event.carrier)

    carrier_sign_in(user)
    visit dashboard_event_path(event)

    expect(page).to have_text(event.id)
  end
end
