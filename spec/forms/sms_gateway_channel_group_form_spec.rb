require "rails_helper"

RSpec.describe SMSGatewayChannelGroupForm do
  describe "validations" do
    it "validates channel is in range" do
      sms_gateway = create(:sms_gateway, max_channels: 2)
      form = SMSGatewayChannelGroupForm.new(
        carrier: sms_gateway.carrier,
        sms_gateway_id: sms_gateway.id,
        channels: [3]
      )

      form.valid?

      expect(form.errors[:channels]).to be_present
    end

    it "validates channel is available" do
      sms_gateway = create(:sms_gateway, max_channels: 2)
      create(:sms_gateway_channel, sms_gateway:, slot_index: 1)
      form = SMSGatewayChannelGroupForm.new(
        carrier: sms_gateway.carrier,
        sms_gateway_id: sms_gateway.id,
        channels: [1]
      )

      form.valid?

      expect(form.errors[:channels]).to be_present
    end
  end
end
