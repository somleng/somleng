require "rails_helper"

RSpec.describe "Admin/SIP Trunks" do
  it "List SIP Trunks" do
    create(:sip_trunk, :fallback, region: :hydrogen, name: "My SIP Trunk")

    page.driver.browser.authorize("admin", "password")
    visit admin_sip_trunks_path

    click_on("My SIP Trunk")

    expect(page).to have_text("My SIP Trunk")
    expect(page).to have_text("hydrogen")
    expect(page).to have_text("Fallback")
  end
end
