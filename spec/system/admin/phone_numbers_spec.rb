require "rails_helper"

RSpec.describe "Admin/Phone Numbers" do
  it "List phone numbers" do
    phone_number = create(
      :phone_number,
      number: "1234",
      iso_country_code: "KH",
      type: :short_code
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_phone_numbers_path

    expect(page).to have_content("1234")
    expect(page).to have_content("Cambodia")
    expect(page).to have_content("short_code")

    click_on("1234")

    expect(page).to have_link(phone_number.carrier.name)
  end
end
