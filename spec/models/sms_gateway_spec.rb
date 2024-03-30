require "rails_helper"

RSpec.describe SMSGateway do
  it "handles connection status" do
    sms_gateway = create(:sms_gateway)
    expect(sms_gateway.connected?).to eq(false)

    sms_gateway.receive_ping
    expect(sms_gateway.connected?).to eq(true)

    sms_gateway.disconnect!
    expect(sms_gateway.connected?).to eq(false)

    sms_gateway.update!(last_connected_at: 5.minutes.ago)
    expect(sms_gateway.connected?).to eq(false)
  end
end
