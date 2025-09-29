module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_sms_gateway

    def connect
      self.current_sms_gateway = SMSGateway.find_by(device_token: request.headers["X-Device-Key"])
      reject_unauthorized_connection if current_sms_gateway.blank?

      authenticate_app_device if current_sms_gateway.device_type == "app"
    end

    def disconnect
      return if current_sms_gateway.blank?

      current_sms_gateway.disconnect!

      ScheduledJob.perform_later(
        ExecuteWorkflowJob.to_s,
        NotifySMSGatewayDown.to_s,
        current_sms_gateway,
        wait_until: 5.minutes.from_now
      )
    end

    private

    def authenticate_app_device
      return reject_unauthorized_connection if request.headers["X-Device-Token"].blank?

      ApplicationPushDevice.create_or_find_by!(
        token: request.headers.fetch("X-Device-Token"),
      ) do |device|
        device.owner = current_sms_gateway
        device.name = request.headers["X-Device-Name"]
        device.platform = "google"
      end
    end
  end
end
