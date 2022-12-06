class SMSGatewayConnectionChannel < ApplicationCable::Channel
  def subscribed
    stream_for(current_sms_gateway)
    ping
  end

  def ping
    current_sms_gateway.receive_ping
  end
end
