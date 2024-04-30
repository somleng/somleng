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

      CreateErrorLog.call(
        type: :sms_gateway_disconnect,
        carrier: current_sms_gateway.carrier,
        error_message: "SMS Gateway: #{current_sms_gateway.name} disconnected."
      )
    end
  end
end
