require "rails_helper"

RSpec.describe "Account Memberships" do
  it "List account memberships" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    other_account = create(:account, carrier:)
    user = create(
      :user, :with_account_membership, account_role: :owner, account:, name: "Joe Bloggs"
    )
    create_account_membership(account:, role: :owner, name: "John Doe")
    create_account_membership(account: other_account, role: :owner, name: "Bob Chann")

    carrier_sign_in(user)
    visit dashboard_account_memberships_path

    expect(page).to have_content("Joe Bloggs")
    expect(page).to have_content("John Doe")
    expect(page).to have_no_content("Bob Chann")
  end

  it "Invite an account member" do
    carrier = create(:carrier)
    user = create(:user, :with_account_membership, carrier:, account_role: :owner)

    carrier_sign_in(user)
    visit dashboard_account_memberships_path

    click_on("New")
    fill_in("Name", with: "John Doe")
    fill_in("Email", with: "johndoe@example.com")
    select("Admin", from: "Role")

    click_on("Send an Invitation")
    expect(page).to have_content("An invitation email has been sent to johndoe@example.com")
    expect(page).to have_content("Admin")
  end

  it "Handle validation errors" do
    carrier = create(:carrier)
    user = create(:user, :with_account_membership, carrier:, account_role: :owner)

    carrier_sign_in(user)
    visit new_dashboard_account_membership_path
    click_on "Send an Invitation"

    expect(page).to have_content("can't be blank")
  end

  it "Update an account membership" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account_role: :owner, account:, carrier:)
    account_membership = create_account_membership(account:, role: :admin)

    carrier_sign_in(user)
    visit dashboard_account_membership_path(account_membership)
    click_on("Edit")

    select("Owner", from: "Role")
    click_on("Update User")

    expect(page).to have_content("Account membership was successfully updated")
    expect(page).to have_content("Owner")
  end

  it "Delete an account membership" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account_role: :owner, account:, carrier:)
    account_member = create(:user, :invited, name: "Bob Chann", carrier:)
    account_membership = create(:account_membership, account:, user: account_member)

    carrier_sign_in(user)
    visit dashboard_account_membership_path(account_membership)
    accept_confirm do
      click_on("Delete")
    end

    expect(page).to have_content("Account membership was successfully destroyed")
    expect(page).to have_no_content("Bob Chann")
  end

  it "Resend invitation" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account:, account_role: :owner, carrier:)
    invited_user = create(:user, :invited, email: "johndoe@example.com", carrier:)
    account_membership = create(:account_membership, account:, user: invited_user)

    carrier_sign_in(user)
    visit dashboard_account_membership_path(account_membership)

    expect(page).to have_content("The user has not yet accepted their invite.")

    perform_enqueued_jobs do
      click_on("Resend")
    end

    expect(page).to have_content("An invitation email has been sent to johndoe@example.com.")
    expect(page).to have_current_path(dashboard_account_membership_path(account_membership))
    expect(last_email_sent).to deliver_to("johndoe@example.com")
  end

  it "Reset 2FA" do
    account = create(:account)
    user = create(:user, :with_account_membership, account:, account_role: :owner)
    account_membership = create_account_membership(account:, email: "johndoe@example.com")

    carrier_sign_in(user)
    visit dashboard_account_membership_path(account_membership)
    click_on("Reset 2FA")

    expect(page).to have_content("2FA was successfully reset for johndoe@example.com")
    expect(page).to have_current_path(dashboard_account_membership_path(account_membership))
  end

  def create_account_membership(account:, role: :admin, **user_attributes)
    user = create(:user, user_attributes)
    create(
      :account_membership,
      account:,
      role:,
      user:,
      created_at: user.created_at
    )
  end
end
