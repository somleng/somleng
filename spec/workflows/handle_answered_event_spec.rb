require "rails_helper"

RSpec.describe HandleAnsweredEvent do
  it "handles answered events" do
    phone_call = create(:phone_call, :ringing)
    event = create(:phone_call_event, :answered, phone_call: phone_call)

    described_class.call(event)

    expect(event.phone_call).to be_answered
  end
end
