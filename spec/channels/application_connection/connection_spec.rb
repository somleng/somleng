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
      sms_gateway = create(:sms_gateway)

      connect("/cable", headers: { "X-Device-Key" => sms_gateway.device_token })
      sms_gateway.receive_ping
      expect(sms_gateway.connected?).to eq(true)

      disconnect

      expect(sms_gateway.connected?).to eq(false)
    end
  end
end
