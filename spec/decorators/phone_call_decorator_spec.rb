require "rails_helper"

RSpec.describe PhoneCallDecorator do
  it "decorates an inbound phone call" do
    phone_call = create(:phone_call, :inbound, status: :session_timeout, from: "16189124649", to: "2442")

    phone_call_decorator = PhoneCallDecorator.new(phone_call)

    expect(phone_call_decorator.to).to eq("2442")
    expect(phone_call_decorator.to_formatted).to eq("2442")
    expect(phone_call_decorator.from).to eq("+16189124649")
    expect(phone_call_decorator.from_formatted).to eq("+1 (618) 912-4649")
    expect(phone_call_decorator.status).to eq("failed")
    expect(phone_call_decorator.price_formatted).to eq(nil)
  end

  it "decorates the phone call direction" do
    expect(PhoneCallDecorator.new(PhoneCall.new(direction: :outbound_api)).direction).to eq("outbound-api")
    expect(PhoneCallDecorator.new(PhoneCall.new(direction: :outbound_dial)).direction).to eq("outbound-dial")
  end
end
