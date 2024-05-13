module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_sms_gateway

    def connect
      self.current_sms_gateway = SMSGateway.find_by(device_token: request.headers["X-Device-Key"])
      reject_unauthorized_connection if current_sms_gateway.blank?
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
  end
end
