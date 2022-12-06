require "rails_helper"

RSpec.describe SMSGatewayChannelGroupForm do
  describe "validations" do
    it "validates channel is in range" do
      sms_gateway = create(:sms_gateway, max_channels: 2)
      channel_group = create(:sms_gateway_channel_group, sms_gateway:)
      form = SMSGatewayChannelGroupForm.initialize_with(channel_group)
      form.channels = [3]

      form.valid?

      expect(form.errors[:channels]).to be_present
    end

    it "validates channel is available" do
      sms_gateway = create(:sms_gateway, max_channels: 2)
      channel_group = create(:sms_gateway_channel_group, sms_gateway:)
      create(:sms_gateway_channel, sms_gateway:, slot_index: 1)
      form = SMSGatewayChannelGroupForm.initialize_with(channel_group)
      form.channels = [1]

      form.valid?

      expect(form.errors[:channels]).to be_present
    end
  end
end
