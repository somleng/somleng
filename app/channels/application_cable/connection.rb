module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_sms_gateway

    def connect
      self.current_sms_gateway = SMSGateway.find_by(device_token: request.headers["X-Device-Key"])
      reject_unauthorized_connection if current_sms_gateway.blank?
    end

    def disconnect
      current_sms_gateway.disconnect!
    end
  end
end
