module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_sms_gateway

    def connect
      self.current_sms_gateway = SMSGateway.find_by!(device_token: request.headers["X-Device-Key"])
    end
  end
end
