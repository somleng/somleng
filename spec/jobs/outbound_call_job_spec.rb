require "rails_helper"

describe OutboundCallJob do
  describe "#perform(phone_call_id)" do
    it "initiates an outbound call" do
      drb_uri = "druby://example.com:9050"
      stub_app_settings(outbound_call_drb_uri: drb_uri)
      phone_call = create(:phone_call)
      external_id = SecureRandom.uuid
      job = described_class.new

      drb_object = spy(DRb::DRbObject, initiate_outbound_call!: external_id)
      allow(DRbObject).to receive(:new_with_uri).and_return(drb_object)

      job.perform(phone_call.id)

      expect(DRbObject).to have_received(:new_with_uri).with(drb_uri)
      expect(drb_object).to have_received(
        :initiate_outbound_call!
      ).with(phone_call.to_internal_outbound_call_json)

      expect(phone_call.reload.external_id).to eq(external_id)
      expect(phone_call).to be_initiated
    end
  end
end
