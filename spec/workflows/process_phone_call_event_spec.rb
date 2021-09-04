require "rails_helper"

RSpec.describe ProcessPhoneCallEvent do
  it "processes a phone call event" do
    phone_call = create(:phone_call, :initiated)

    event = ProcessPhoneCallEvent.call(
      phone_call: phone_call.external_id,
      type: "answered",
      params: {
        "foo" => "bar"
      }
    )

    expect(event).to have_attributes(
      type: "answered",
      params: {
        "foo" => "bar"
      },
      phone_call: phone_call
    )
  end

  it "handles race conditions" do
    params = {
      phone_call: SecureRandom.uuid,
      type: "answered"
    }

    expect { ProcessPhoneCallEvent.call(params) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
