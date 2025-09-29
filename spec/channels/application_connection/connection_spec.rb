require "rails_helper"

module ApplicationCable
  RSpec.describe Connection, type: :channel do
    describe "connect" do
      context "when the device is a gateway" do
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
      end

      context "when the device is an app" do
        it "successfully connects with app device" do
          sms_gateway = create(:sms_gateway, device_type: :app)

          connect(
            "/cable",
            headers: {
              "X-Device-Key" => sms_gateway.device_token,
              "X-Device-Token" => "abc123",
              "X-Device-Name" => "Oppo A57"
            }
          )

          expect(connection.current_sms_gateway).to eq(sms_gateway)
          expect(connection.current_sms_gateway.app_devices.count).to eq(1)
          expect(connection.current_sms_gateway.app_devices[0]).to have_attributes(
            token: "abc123",
            name: "Oppo A57",
            platform: "google"
          )
        end

        it "rejects connection if the device token is missing" do
          expect {
            sms_gateway = create(:sms_gateway, device_type: :app)

            connect(
              "/cable",
              headers: {
                "X-Device-Key" => sms_gateway.device_token,
                "X-Device-Token" => nil
              }
            )
          }.to have_rejected_connection
        end
      end
    end

    it "successfully disconnects" do
      travel_to(Time.current) do
        sms_gateway = create(:sms_gateway, name: "My SMS Gateway")

        connect("/cable", headers: { "X-Device-Key" => sms_gateway.device_token })
        sms_gateway.receive_ping
        expect(sms_gateway.connected?).to eq(true)

        disconnect

        expect(ScheduledJob).to have_been_enqueued.with(
          "ExecuteWorkflowJob",
          "NotifySMSGatewayDown",
          sms_gateway,
          wait_until: 5.minutes.from_now
        )
        expect(sms_gateway.reload.connected?).to eq(false)
      end
    end
  end
end
