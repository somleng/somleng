require "rails_helper"

RSpec.describe NotifySMSGatewayDown do
  it "notifies when the SMS Gateway is down" do
    sms_gateway = create(:sms_gateway, :disconnected, name: "My SMS Gateway")

    NotifySMSGatewayDown.call(sms_gateway)

    expect(ErrorLog.last).to have_attributes(
      carrier: sms_gateway.carrier,
      error_message: "SMS Gateway: 'My SMS Gateway' was disconnected.",
      type: "sms_gateway_disconnect"
    )
  end

  it "does not notify if the SMS Gateway Gateway back up up" do
    sms_gateway = create(:sms_gateway, :connected,)

    NotifySMSGatewayDown.call(sms_gateway)

    expect(ErrorLog.all).to be_empty
  end
end
