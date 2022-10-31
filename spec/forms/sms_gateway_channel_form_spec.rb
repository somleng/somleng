require "rails_helper"

RSpec.describe SMSGatewayChannelForm do
  describe "validations" do
    it "validates the number is unique for the sms gateway" do
      carrier = create(:carrier)
      sms_gateway = create(:sms_gateway, carrier:)
      create(:sms_gateway_channel, sms_gateway:, number: 1)

      form = SMSGatewayChannelForm.new(carrier:, sms_gateway_id: sms_gateway.id, number: 1)

      expect(form).to be_invalid
      expect(form.errors[:number]).to be_present
    end

    it "validates updates on edit" do
      carrier = create(:carrier)
      sms_gateway = create(:sms_gateway, carrier:)
      channel = create(:sms_gateway_channel, sms_gateway:, number: 1)

      form = SMSGatewayChannelForm.new(
        carrier:,
        sms_gateway_channel: channel,
        sms_gateway_id: sms_gateway.id,
        number: 1
      )

      form.valid?

      expect(form.errors[:number]).to be_blank
    end
  end
end
