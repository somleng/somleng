require "rails_helper"

RSpec.describe "Authentication" do
  it "Sign in with OTP" do
    carrier = create_carrier
    user = create(:user, :carrier, carrier:, password: "Super Secret")

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    fill_in("OTP Code", with: user.current_otp)
    click_on("Login")

    expect(page).to have_content("Signed in successfully")
  end

  it "Handles captcha", :js, :allow_net_connect, :captcha do
    stub_app_settings(recaptcha_minimum_score: 1)
    carrier = create_carrier
    user = create(:user, :carrier, carrier:, password: "Super Secret")

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    fill_in("OTP Code", with: user.current_otp)
    click_on("Login")

    expect(page).to have_field("Email", with: user.email)
    expect(page).to have_xpath("//iframe[@title='reCAPTCHA']")
  end

  it "Requires a valid OTP" do
    carrier = create_carrier
    user = create(:user, carrier:, password: "Super Secret")

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    fill_in("OTP Code", with: "wrong-otp")
    click_on("Login")

    expect(page).to have_content("Invalid Email or password")
  end

  it "Sign in without OTP" do
    carrier = create_carrier
    user = create(:user, :carrier, carrier:, password: "Super Secret", otp_required_for_login: false)

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    click_on("Login")

    expect(page).to have_content("Setup Two Factor Authentication")

    fill_in("OTP Code", with: user.current_otp)
    click_on("Enable")

    expect(page).to have_content("2FA was successfully enabled")
  end

  it "Accept an invitation from a carrier" do
    carrier = create_carrier
    perform_enqueued_jobs do
      User.invite!(
        email: "new_user@example.com",
        name: "John Doe",
        carrier_role: :member,
        carrier:
      )
    end

    open_email("new_user@example.com")
    visit_full_link_in_email("Accept invitation")

    fill_in("Password", with: "password123")
    fill_in("Password confirmation", with: "password123")
    click_on("Set my password")

    expect(page).to have_content("Setup Two Factor Authentication")
  end

  it "Accept an invitation from an account owner" do
    carrier = create_carrier
    account = create(:account, carrier:)
    perform_enqueued_jobs do
      user = User.invite!(
        carrier: account.carrier,
        email: "johndoe@example.com",
        name: "John Doe"
      )
      create(:account_membership, account:, user:)
    end

    open_email("johndoe@example.com")
    visit_full_link_in_email("Accept invitation")
    fill_in("Password", with: "password123")
    fill_in("Password confirmation", with: "password123")
    click_on("Set my password")

    expect(page).to have_content("Setup Two Factor Authentication")
  end

  it "User can reset their password" do
    carrier = create_carrier
    user = create(:user, :carrier, carrier:, email: "user@example.com")

    visit(new_user_session_path)
    click_on("Forgot your password?")
    fill_in("Email", with: user.email)
    perform_enqueued_jobs do
      click_on("Send me reset password instructions")
    end

    open_email("user@example.com")
    visit_full_link_in_email("Change my password")
    fill_in("New password", with: "Super Secret")
    fill_in("Confirm your new password", with: "Super Secret")
    click_on("Change my password")

    expect(page).to have_content("Your password has been changed successfully.")

    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    fill_in("OTP Code", with: user.current_otp)
    click_on("Login")

    expect(page).to have_content("Signed in successfully.")
  end

  it "Handles users with with no account memberships" do
    user = create(:user)

    carrier_sign_in(user)
    visit(dashboard_root_path)

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("You are not a member of any accounts")
  end

  it "Handles users without a default account membership" do
    carrier = create(:carrier)
    user = create(:user, carrier:)
    account = create(:account, carrier:, name: "Rocket Rides")
    create(:account_membership, user:, account:)

    carrier_sign_in(user)
    visit(dashboard_root_path)

    expect(page).to have_current_path(dashboard_account_settings_path)
    expect(page).to have_content("Rocket Rides")
  end

  it "Blocks cross domain logins" do
    carrier = create(:carrier)
    user = create(:user, carrier:, email: "user@carrier.com", password: "password123")
    create_carrier

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "password123")
    click_on("Login")

    expect(page).to have_content("Invalid Email or password")
  end

  it "Handles locking and unlocking a user" do
    carrier = create_carrier
    user = create(:user, :carrier, carrier:, email: "user@example.com", password: "password123")

    visit(new_user_session_path)

    fill_in("Email", with: "user@example.com")

    5.times do
      fill_in("Password", with: "password123")
      fill_in("OTP Code", with: "123456")
      perform_enqueued_jobs do
        click_on("Login")
      end
    end

    expect(page).to have_content("Your account is locked.")
    expect(last_email_sent).to deliver_to("user@example.com")
    expect(last_email_sent).to have_subject("Unlock instructions")

    click_on("Didn't receive unlock instructions?")
    fill_in("Email", with: "user@example.com")
    perform_enqueued_jobs do
      click_on("Resend unlock instructions")
    end

    expect(page).to have_content("You will receive an email with instructions for how to unlock your account in a few minutes.")

    open_last_email_for("user@example.com")
    visit_full_link_in_email("Unlock my account")

    expect(page).to have_content("Your account has been unlocked successfully. Please sign in to continue.")

    fill_in("Email", with: "user@example.com")
    fill_in("Password", with: "password123")
    fill_in("OTP Code", with: user.current_otp)
    click_on("Login")

    expect(page).to have_content("Signed in successfully.")
  end

  def create_carrier(*args)
    carrier = create(:carrier, *args)
    Capybara.app_host = "http://#{carrier.subdomain_host}"
    carrier
  end
end
