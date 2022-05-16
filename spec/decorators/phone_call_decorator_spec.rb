require "rails_helper"

RSpec.describe PhoneCallDecorator do
  it "decorates the phone number" do
    phone_call = create(:phone_call, from: "16189124649", to: "2442")

    phone_call_decorator = PhoneCallDecorator.new(phone_call)

    expect(phone_call_decorator.to).to eq("2442")
    expect(phone_call_decorator.to_formatted).to eq("2442")
    expect(phone_call_decorator.from).to eq("+16189124649")
    expect(phone_call_decorator.from_formatted).to eq("+1 (618) 912-4649")
  end
end