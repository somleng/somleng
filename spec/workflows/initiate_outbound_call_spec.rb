require "rails_helper"

RSpec.describe InitiateOutboundCall do
  it "initiates an outbound call" do
    drb_uri = "druby://example.com:9050"
    stub_app_settings(outbound_call_drb_uri: drb_uri)
    phone_call = create(:phone_call)
    external_id = SecureRandom.uuid
    drb_object = stub_drb_object(initiate_outbound_call!: external_id)

    described_class.call(phone_call)

    expect(DRbObject).to have_received(:new_with_uri).with(drb_uri)
    expect(drb_object).to have_received(
      :initiate_outbound_call!
    ).with(API::Internal::PhoneCallSerializer.new(phone_call).to_json)
    expect(phone_call.reload.external_id).to eq(external_id)
    expect(phone_call).to be_initiated
  end
end
