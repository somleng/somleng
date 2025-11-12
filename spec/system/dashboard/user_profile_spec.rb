require "rails_helper"

RSpec.describe "User profile" do
  it "Update user profile" do
    carrier = create(:carrier)
    user = create(
      :user,
      :carrier,
      carrier:, name: "John Doe",
      email: "johndoe@example.com",
      password: "current password"
    )

    carrier_sign_in(user)
    visit(dashboard_root_path)

    click_on("Profile Menu")
    click_on("Profile")
    fill_in("Name", with: "Bob Chan")
    fill_in("Email", with: "bobchan@example.com")
    fill_in("Password", with: "new password")
    fill_in("Password confirmation", with: "new password")
    fill_in("Current password", with: "current password")

    perform_enqueued_jobs do
      click_on("Update")
    end

    expect(page).to have_content("You updated your account successfully, but we need to verify your new email address")
    expect(page).to have_content("Currently waiting confirmation for: bobchan@example.com")
    expect(page).to have_field("Name", with: "Bob Chan")
    expect(page).to have_field("Email", with: "johndoe@example.com")

    open_email("bobchan@example.com")
    visit_in_email("Confirm my account")
    expect(page).to have_content("Your email address has been successfully confirmed")

    visit(edit_user_registration_path)
    expect(page).to have_field("Email", with: "bobchan@example.com")
  end
end
