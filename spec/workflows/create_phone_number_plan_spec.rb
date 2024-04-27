require "rails_helper"

RSpec.describe CreatePhoneNumberPlan do
  it "creates a phone number plan" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    phone_number = create(:phone_number, carrier:, number: "12513095500")

    plan = CreatePhoneNumberPlan.call(
      phone_number:,
      account:,
      voice_url: "https://example.com/voice.xml"
    )

    expect(plan).to have_attributes(
      persisted?: true,
      account:,
      phone_number:,
      number: phone_number.number,
      amount: phone_number.price,
      incoming_phone_number: have_attributes(
        persisted?: true,
        phone_number:,
        account:,
        number: phone_number.number,
        account_type: account.type,
        friendly_name: "+1 (251) 309-5500",
        voice_url: "https://example.com/voice.xml"
      )
    )
  end

  it "overrides the amount" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    phone_number = create(:phone_number, carrier:, number: "12513095500")

    plan = CreatePhoneNumberPlan.call(
      phone_number:,
      account:,
      amount: Money.from_amount(5.00, "USD")
    )

    expect(plan).to have_attributes(
      amount: Money.from_amount(5.00, "USD")
    )
  end
end
