require "rails_helper"

RSpec.describe "Admin/Phone Numbers" do
  it "List phone numbers" do
    phone_number = create(:phone_number, :assigned_to_account, number: "1234", iso_country_code: "KH")
    create(
      :phone_number_configuration,
      phone_number:,
      voice_url: "https://demo.twilio.com/docs/voice.xml"
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_phone_numbers_path

    expect(page).to have_content("1234")
    expect(page).to have_content("Cambodia")

    click_on("1234")

    expect(page).to have_link(phone_number.carrier.name)
    expect(page).to have_link(phone_number.account.name)
    expect(page).to have_content("https://demo.twilio.com/docs/voice.xml")

    click_on(phone_number.configuration.id)
    expect(page).to have_content("https://demo.twilio.com/docs/voice.xml")
  end
end
