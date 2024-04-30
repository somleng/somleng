require "rails_helper"

RSpec.describe "Notification settings" do
  it "Update notification settings" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit(dashboard_root_path)

    click_on("Profile Menu")
    click_on("Notifications")

    check("Inbound message")
    check("Inbound call")
    click_on("Save")

    expect(page).to have_content("Notification preferences were successfully updated.")

    expect(page).to have_field("Inbound message", checked: true)
    expect(page).to have_field("Inbound call", checked: true)

    uncheck("Inbound call")
    click_on("Save")

    expect(page).to have_field("Inbound call", checked: false)
  end
end
