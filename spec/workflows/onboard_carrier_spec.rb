require "rails_helper"

RSpec.describe OnboardCarrier do
  it "onboards a new carrier" do
    rating_engine_client = instance_spy(RatingEngineClient)

    carrier, owner = OnboardCarrier.call(
      name: "AT&T",
      country_code: "US",
      website: "https://www.att.com",
      restricted: true,
      subdomain: "at-t",
      owner: {
        name: "John Doe",
        email: "johndoe@example.com"
      },
      rating_engine_client:
    )

    expect(carrier).to have_attributes(
      name: "AT&T",
      country_code: "US",
      api_key: be_present,
      oauth_application: be_present,
      restricted: true,
      subdomain: "at-t"
    )

    expect(owner).to have_attributes(
      name: "John Doe",
      email: "johndoe@example.com",
      carrier_role: "owner"
    )

    expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
    expect(rating_engine_client).to have_received(:upsert_charging_profile).with(carrier)
  end
end
