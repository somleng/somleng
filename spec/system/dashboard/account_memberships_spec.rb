require "rails_helper"

RSpec.describe "Account Memberships" do
  it "List and filter account memberships" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    account = create(:account, carrier: carrier)
    other_account = create(:account, carrier: carrier, name: "Rocket Rides")
    create_account_membership(account: account, name: "John Doe", created_at: Time.utc(2021, 12, 1))
    create_account_membership(account: account, name: "Joe Bloggs", created_at: Time.utc(2021, 10, 10))
    create_account_membership(account: other_account, name: "Magic Johnson", created_at: Time.utc(2021, 12, 1))

    sign_in(user)
    visit dashboard_account_memberships_path(account, filter: { from_date: "01/12/2021", to_date: "15/12/2021" })

    expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
    expect(page).to have_content("John Doe")
    expect(page).not_to have_content("Joe Bloggs")
    expect(page).not_to have_content("Magic Johnson")
  end

  it "Create a new account membership" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier: carrier)
    account = create(:account, carrier: carrier, name: "Rocket Rides")

    sign_in(user)
    visit dashboard_account_path(account)
    click_link("Manage account memberships")
    click_link("New")

    expect(page).to have_link("Rocket Rides", href: dashboard_account_memberships_path(account))

    fill_in("Name", with: "John Doe")
    fill_in("Email", with: "johndoe@example.com")
    select("Owner", from: "Role")

    perform_enqueued_jobs do
      click_button("Send an invitation")
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com")
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Handle validation errors" do
    user = create(:user, :carrier, :admin)
    account = create(:account, carrier: user.carrier)

    sign_in(user)
    visit new_dashboard_account_membership_path(account)
    click_button "Send an invitation"

    expect(page).to have_content("can't be blank")
  end

  it "Update an account membership" do
    user = create(:user, :carrier, :admin)
    account = create(:account, carrier: user.carrier)
    account_membership = create_account_membership(account: account, role: :admin)

    sign_in(user)
    visit dashboard_account_membership_path(account, account_membership)
    click_link("Edit")

    select("Owner", from: "Role")
    click_button "Update Account Membership"

    expect(page).to have_content("Account membership was successfully updated")
    expect(page).to have_content("Owner")
  end

  it "Delete an account membership" do
    user = create(:user, :carrier, :admin)
    account = create(:account, carrier: user.carrier)
    account_membership = create_account_membership(account: account, name: "Bob Chann")

    sign_in(user)
    visit edit_dashboard_account_membership_path(account, account_membership)
    click_link("Delete")

    expect(page).to have_content("Account membership was successfully destroyed")
    expect(page).not_to have_content("Bob Chann")
  end

  def create_account_membership(account:, role: :admin, **user_attributes)
    user = create(:user, *user_attributes)
    create(:account_membership, account: account, role: role, user: user, created_at: user.created_at)
  end
end
