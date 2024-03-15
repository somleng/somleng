require "rails_helper"

RSpec.describe "Notification settings" do
  it "Update notification settings" do
    carrier = create(:carrier)
    user = create(:user, :carrier)

    carrier_sign_in(user)
    visit(dashboard_root_path)

    click_on("Profile Menu")
    click_on("Notifications")
    check("Error logs")
    click_on("Save")

    expect(page).to have_content("Notification preferences were successfully updated.")
    expect(page).to have_field("Error logs", checked: true)

    uncheck("Error logs")
    click_on("Save")

    expect(page).to have_field("Error logs", checked: false)
  end
end
