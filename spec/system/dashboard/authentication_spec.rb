require "rails_helper"

RSpec.describe "Authentication" do
  it "Sign in with OTP" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, :carrier, carrier:, password: "Super Secret")

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    fill_in("OTP Code", with: user.current_otp)
    click_button("Login")

    expect(page).to have_content("Signed in successfully")
  end

  it "Requires a valid OTP" do
    carrier = create(:carrier)
    user = create(:user, carrier:, password: "Super Secret")

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    fill_in("OTP Code", with: "wrong-otp")
    click_button("Login")

    expect(page).to have_content("Invalid Email or password")
  end

  it "Sign in without OTP" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, :carrier, carrier:, password: "Super Secret", otp_required_for_login: false)

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    click_button("Login")

    expect(page).to have_content("Setup Two Factor Authentication")

    fill_in("OTP Code", with: user.current_otp)
    click_button("Enable")

    expect(page).to have_content("2FA was successfully enabled")
  end

  it "Accept an invitation from a carrier" do
    carrier = create(:carrier)
    perform_enqueued_jobs do
      User.invite!(
        email: "new_user@example.com",
        name: "John Doe",
        carrier_role: :member,
        carrier:
      )
    end

    open_email("new_user@example.com")
    visit_in_email("Accept invitation")
    expect(current_url).to match("dashboard")

    fill_in("Password", with: "password123")
    fill_in("Password confirmation", with: "password123")
    click_button("Set my password")

    expect(page).to have_content("Setup Two Factor Authentication")
  end

  it "Accept an invitation from an account owner" do
    account = create(:account)
    perform_enqueued_jobs do
      user = User.invite!(
        carrier: account.carrier,
        email: "johndoe@example.com",
        name: "John Doe"
      )
      create(:account_membership, account:, user:)
    end

    open_email("johndoe@example.com")
    visit_in_email("Accept invitation")
    fill_in("Password", with: "password123")
    fill_in("Password confirmation", with: "password123")
    click_button("Set my password")

    expect(page).to have_content("Setup Two Factor Authentication")
  end

  it "User can reset their password" do
    carrier = create(:carrier, :with_oauth_application)
    user = create(:user, :carrier, carrier:, email: "user@example.com")

    visit(new_user_session_path)
    click_link("Forgot your password?")
    fill_in("Email", with: user.email)
    perform_enqueued_jobs do
      click_button("Send me reset password instructions")
    end

    open_email("user@example.com")
    visit_in_email("Change my password")
    fill_in("New password", with: "Super Secret")
    fill_in("Confirm your new password", with: "Super Secret")
    click_button("Change my password")

    expect(page).to have_content("Your password has been changed successfully. You are now signed in")
  end

  it "Handles users with with no account memberships" do
    user = create(:user)

    sign_in(user)
    visit(dashboard_root_path)

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("You are not a member of any accounts")
  end

  it "Handles users without a default account membership" do
    carrier = create(:carrier)
    user = create(:user, carrier:)
    account = create(:account, carrier:, name: "Rocket Rides")
    create(:account_membership, user:, account:)

    sign_in(user)
    visit(dashboard_root_path)

    expect(page).to have_current_path(dashboard_account_settings_path)
    expect(page).to have_content("Rocket Rides")
  end
end
