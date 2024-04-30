require "rails_helper"

module ApplicationCable
  RSpec.describe Connection, type: :channel do
    it "successfully connects" do
      sms_gateway = create(:sms_gateway)

      connect("/cable", headers: { "X-Device-Key" => sms_gateway.device_token })

      expect(connection.current_sms_gateway).to eq(sms_gateway)
    end

    it "rejects connection" do
      expect {
        connect("/cable", headers: { "X-Device-Key" => "invalid-token" })
      }.to have_rejected_connection
    end

    it "successfully disconnects" do
      sms_gateway = create(:sms_gateway, name: "My SMS Gateway")

      connect("/cable", headers: { "X-Device-Key" => sms_gateway.device_token })
      sms_gateway.receive_ping
      expect(sms_gateway.connected?).to eq(true)

      disconnect

      expect(sms_gateway.reload.connected?).to eq(false)

      expect(ErrorLog.last).to have_attributes(
        carrier: sms_gateway.carrier,
        error_message: "SMS Gateway: 'My SMS Gateway' was disconnected.",
        type: "sms_gateway_disconnect"
      )
    end
  end
end
