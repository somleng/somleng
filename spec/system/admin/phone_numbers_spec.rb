require "rails_helper"

RSpec.describe "Admin/Phone Numbers" do
  it "show a phone number" do
    carrier = create(:carrier, name: "My Carrier")
    account = create(:account, carrier:, name: "Rocket Rides")
    phone_number = create(:phone_number, account:, carrier:, number: "1234")
    create(
      :phone_number_configuration,
      phone_number:,
      voice_url: "https://demo.twilio.com/docs/voice.xml"
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_carrier_path(carrier)

    click_link("1234")
    expect(page).to have_link("My Carrier")
    expect(page).to have_link("Rocket Rides")
    expect(page).to have_content("https://demo.twilio.com/docs/voice.xml")

    click_link(phone_number.configuration.id)
    expect(page).to have_content("https://demo.twilio.com/docs/voice.xml")
  end
end
