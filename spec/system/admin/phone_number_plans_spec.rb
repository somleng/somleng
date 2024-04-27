require "rails_helper"

RSpec.describe "Admin/Phone Number Plans" do
  it "List incoming phone numbers" do
    phone_number_plan = create(
      :phone_number_plan,
      number: "12513095500"
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_phone_number_plans_path

    expect(page).to have_content("12513095500")

    click_on("12513095500")

    expect(page).to have_content(phone_number_plan.id)
  end
end
