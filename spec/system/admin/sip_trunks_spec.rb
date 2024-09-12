require "rails_helper"

RSpec.describe "Admin/SIP Trunks" do
  it "List SIP Trunks" do
    create(:sip_trunk, region: :hydrogen, name: "My SIP Trunk")

    page.driver.browser.authorize("admin", "password")
    visit admin_sip_trunks_path

    click_on("My SIP Trunk")

    expect(page).to have_content("My SIP Trunk")
    expect(page).to have_content("hydrogen")
  end
end
