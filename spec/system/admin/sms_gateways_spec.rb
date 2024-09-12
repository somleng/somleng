require "rails_helper"

RSpec.describe "Admin/SMS Gateways" do
  it "List SIP Trunks" do
    create(:sms_gateway, name: "My SMS Gateway")

    page.driver.browser.authorize("admin", "password")
    visit admin_sms_gateways_path

    click_on("My SMS Gateway")

    expect(page).to have_content("My SMS Gateway")
  end
end
