require "rails_helper"

RSpec.describe "Carrier users" do
  it "List and filter users" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(:user, :carrier, name: "John Doe", carrier:, created_at: Time.utc(2021, 12, 1))
    create(:user, :carrier, name: "Joe Bloggs", carrier:,
                            created_at: Time.utc(2021, 10, 10))

    carrier_sign_in(user)
    visit dashboard_carrier_users_path(filter: { from_date: "01/12/2021", to_date: "15/12/2021" })

    expect(page).to have_content("John Doe")
    expect(page).to have_no_content("Joe Bloggs")
  end

  it "Carrier owner invites another user" do
    user = create(:user, :carrier, :owner)

    carrier_sign_in(user)
    visit dashboard_carrier_users_path
    click_on("New")
    fill_in("Name", with: "John Doe")
    fill_in("Email", with: "johndoe@example.com")
    select("Admin", from: "Role")
    perform_enqueued_jobs do
      click_on "Send an invitation"
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com")
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Handle validation errors" do
    user = create(:user, :carrier, :owner)

    carrier_sign_in(user)
    visit new_dashboard_carrier_user_path
    click_on "Send an invitation"

    expect(page).to have_content("can't be blank")
  end

  it "Carrier owner can update a user" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :owner, carrier:)
    managed_user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_carrier_user_path(managed_user)
    click_on("Edit")

    select("Member", from: "Role")
    click_on "Update User"

    expect(page).to have_content("User was successfully updated")
    expect(page).to have_content("Member")
  end

  it "Resend invitation" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :owner, carrier:)
    invited_user = create(
      :user,
      :carrier,
      :admin,
      :invited,
      carrier:,
      email: "johndoe@example.com"
    )

    carrier_sign_in(user)
    visit dashboard_carrier_user_path(invited_user)

    expect(page).to have_content("The user has not yet accepted their invite.")

    perform_enqueued_jobs do
      click_on("Resend")
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com.")
    expect(page).to have_current_path(dashboard_carrier_user_path(invited_user))
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Reset 2FA for a user" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :owner, carrier:)
    other_user = create(
      :user,
      :carrier,
      :admin,
      :otp_required_for_login,
      carrier:,
      email: "johndoe@example.com"
    )

    carrier_sign_in(user)
    visit dashboard_carrier_user_path(other_user)

    click_on("Reset 2FA")

    expect(page).to have_content("2FA was successfully reset for johndoe@example.com")
    expect(page).to have_current_path(dashboard_carrier_user_path(other_user))
  end

  it "Delete a user" do
    user = create(:user, :carrier, :owner)
    user_to_delete = create(
      :user,
      :carrier,
      name: "Joe Bloggs",
      carrier: user.carrier
    )
    create(:export, user: user_to_delete)

    carrier_sign_in(user)
    visit dashboard_carrier_user_path(user_to_delete)

    click_on "Delete"

    expect(page).to have_no_content("Joe Bloggs")
  end
end
