require "rails_helper"

RSpec.describe "Account Memberships" do
  it "List and filter account memberships as a carrier" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    account = create(:account, carrier: carrier)
    create_account_membership(account: account, name: "John Doe", created_at: Time.utc(2021, 12, 1))
    create_account_membership(account: account, name: "Joe Bloggs", created_at: Time.utc(2021, 10, 10))

    sign_in(user)
    visit dashboard_account_memberships_path(
      filter: { from_date: "01/12/2021", to_date: "15/12/2021" }
    )

    expect(page).to have_content("John Doe")
    expect(page).not_to have_content("Joe Bloggs")
  end

  it "List account memberships as an account owner" do
    account = create(:account)
    other_account = create(:account, carrier: account.carrier)
    user = create(
      :user, :with_account_membership, account_role: :owner, account: account, name: "Joe Bloggs"
    )
    create_account_membership(account: account, role: :owner, name: "John Doe")
    create_account_membership(account: other_account, role: :owner, name: "Bob Chann")

    sign_in(user)
    visit dashboard_account_memberships_path

    expect(page).to have_content("Joe Bloggs")
    expect(page).to have_content("John Doe")
    expect(page).not_to have_content("Bob Chann")
  end

  it "Create a new account membership as a carrier", :js do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier: carrier)
    create(:account, carrier: carrier, name: "Rocket Rides")

    sign_in(user)
    visit dashboard_account_memberships_path

    click_link("New")
    fill_in("Name", with: "John Doe")
    fill_in("Email", with: "johndoe@example.com")
    select("Rocket Rides", from: "Account")

    perform_enqueued_jobs do
      click_button("Send an Invitation")
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com")
    expect(page).to have_content("Owner")
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Invite an account member" do
    user = create(:user, :with_account_membership, account_role: :owner)

    sign_in(user)
    visit dashboard_account_memberships_path

    click_link("New")
    fill_in("Name", with: "John Doe")
    fill_in("Email", with: "johndoe@example.com")
    select("Admin", from: "Role")

    click_button("Send an Invitation")
    expect(page).to have_content("An invitation email has been sent to johndoe@example.com")
    expect(page).to have_content("Admin")
  end

  it "Handle validation errors" do
    user = create(:user, :carrier, :admin)
    account = create(:account, carrier: user.carrier)

    sign_in(user)
    visit new_dashboard_account_membership_path(account)
    click_button "Send an Invitation"

    expect(page).to have_content("can't be blank")
  end

  it "Update an account membership" do
    account = create(:account)
    user = create(:user, :with_account_membership, account_role: :owner, account: account)
    account_membership = create_account_membership(account: account, role: :admin)

    sign_in(user)
    visit dashboard_account_membership_path(account_membership)
    click_link("Edit")

    select("Owner", from: "Role")
    click_button "Update Account Membership"

    expect(page).to have_content("Account membership was successfully updated")
    expect(page).to have_content("Owner")
  end

  it "Delete an account membership" do
    user = create(:user, :carrier, :admin)
    account = create(:account, carrier: user.carrier)
    account_member = create(:user, :invited, name: "Bob Chann")
    account_membership = create(:account_membership, account: account, user: account_member)

    sign_in(user)
    visit dashboard_account_membership_path(account_membership)
    click_link("Delete")

    expect(page).to have_content("Account membership was successfully destroyed")
    expect(page).not_to have_content("Bob Chann")
  end

  it "Resend invitation" do
    user = create(:user, :carrier, :admin)
    account = create(:account, carrier: user.carrier)
    invited_user = create(:user, :invited, email: "johndoe@example.com")
    account_membership = create(:account_membership, account: account, user: invited_user)

    sign_in(user)
    visit dashboard_account_membership_path(account_membership)

    expect(page).to have_content("The user has not yet accepted their invite.")

    perform_enqueued_jobs do
      click_link("Resend")
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com.")
    expect(page).to have_current_path(dashboard_account_membership_path(account_membership))
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  def create_account_membership(account:, role: :admin, **user_attributes)
    user = create(:user, user_attributes)
    create(
      :account_membership,
      account: account,
      role: role,
      user: user,
      created_at: user.created_at
    )
  end
end
