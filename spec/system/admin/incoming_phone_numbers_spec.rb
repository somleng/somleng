require "rails_helper"

RSpec.describe "Admin/Incoming Phone Numbers" do
  it "List incoming phone numbers" do
    incoming_phone_number = create(
      :incoming_phone_number,
      number: "12513095500"
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_incoming_phone_numbers_path

    expect(page).to have_content("12513095500")

    click_on("12513095500")

    expect(page).to have_content(incoming_phone_number.id)
  end
end
