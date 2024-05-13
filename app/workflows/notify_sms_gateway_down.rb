class NotifySMSGatewayDown < ApplicationWorkflow
  attr_reader :sms_gateway

  def initialize(sms_gateway)
    @sms_gateway = sms_gateway
  end

  def call
    return if sms_gateway.connected?

    CreateErrorLog.call(
      type: :sms_gateway_disconnect,
      carrier: sms_gateway.carrier,
      error_message: "SMS Gateway: '#{sms_gateway.name}' was disconnected."
    )
  end
end
