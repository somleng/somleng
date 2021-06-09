require "rails_helper"

RSpec.describe "Users" do
  it "List and filter users" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    create(:user, :carrier, name: "John Doe", carrier: carrier, created_at: Time.utc(2021, 12, 1))
    create(:user, :carrier, name: "Joe Bloggs", carrier: carrier, created_at: Time.utc(2021, 10, 10))

    sign_in(user)
    visit dashboard_users_path(filter: { from_date: "01/12/2021", to_date: "15/12/2021" })

    expect(page).to have_content("John Doe")
    expect(page).not_to have_content("Joe Bloggs")
  end

  it "Carrier owner invites another user" do
    user = create(:user, :carrier, :owner)

    sign_in(user)
    visit dashboard_users_path
    click_link("New")
    fill_in("Name", with: "John Doe")
    fill_in("Email", with: "johndoe@example.com")
    select("Admin", from: "Role")
    perform_enqueued_jobs do
      click_button "Send an invitation"
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com")
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Handle validation errors" do
    user = create(:user, :carrier, :owner)

    sign_in(user)
    visit new_dashboard_user_path
    click_button "Send an invitation"

    expect(page).to have_content("can't be blank")
  end

  it "Carrier owner can update a user" do
    user = create(:user, :carrier, :owner)

    sign_in(user)
    visit dashboard_user_path(user)
    click_link("Edit")

    select("Member", from: "Role")
    click_button "Update User"

    expect(page).to have_content("User was successfully updated")
    expect(page).to have_content("Member")
  end

  it "Resend invitation" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :owner, carrier: carrier)
    invited_user = create(:user, :carrier, :admin, :invited, carrier: carrier, email: "johndoe@example.com")

    sign_in(user)
    visit dashboard_user_path(invited_user)

    expect(page).to have_content("The user has not yet accepted their invite.")

    perform_enqueued_jobs do
      click_link("Resend")
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com.")
    expect(page).to have_current_path(dashboard_user_path(invited_user))
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end
end
