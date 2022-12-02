require "rails_helper"

RSpec.describe SMSGatewayConnectionChannel, type: :channel do
  describe "#ping" do
    it "updates the connection status" do
      sms_gateway = stub_current_sms_gateway

      subscribe
      perform(:ping)

      expect(sms_gateway.connected?).to eq(true)
    end
  end

  def stub_current_sms_gateway
    sms_gateway = create(:sms_gateway)
    stub_connection(current_sms_gateway: sms_gateway)
    sms_gateway
  end
end
