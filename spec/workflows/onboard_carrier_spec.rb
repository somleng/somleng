require "rails_helper"

RSpec.describe OnboardCarrier do
  it "onboards a new carrier" do
    carrier = OnboardCarrier.call(
      name: "AT&T",
      country_code: "US",
      owner: {
        name: "John Doe",
        email: "johndoe@example.com"
      }
    )

    expect(carrier).to have_attributes(
      name: "AT&T",
      country_code: "US",
      api_key: be_present,
      oauth_application: be_present,
      users: [
        have_attributes(
          name: "John Doe",
          email: "johndoe@example.com"
        )
      ]
    )
    expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
  end
end