require "rails_helper"

RSpec.describe "Authentication" do
  it "Sign in with OTP" do
    user = create(:user, :carrier, password: "Super Secret")

    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    fill_in("OTP Code", with: user.current_otp)
    click_button("Login")

    expect(page).to have_content("Signed in successfully")
  end

  it "Sign in without OTP" do
    user = create(:user, :carrier, password: "Super Secret", otp_required_for_login: false)

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
        carrier: carrier
      )
    end

    open_email("new_user@example.com")
    visit_in_email("Accept invitation")
    fill_in("Password", with: "password123")
    fill_in("Password confirmation", with: "password123")
    click_button("Set my password")

    expect(page).to have_content("Setup Two Factor Authentication")
  end

  it "Accept an invitation from an account owner" do
    account = create(:account)
    perform_enqueued_jobs do
      user = User.invite!(
        email: "johndoe@example.com",
        name: "John Doe"
      )
      create(:account_membership, account: account, user: user)
    end

    open_email("johndoe@example.com")
    visit_in_email("Accept invitation")
    fill_in("Password", with: "password123")
    fill_in("Password confirmation", with: "password123")
    click_button("Set my password")

    expect(page).to have_content("Setup Two Factor Authentication")
  end
end
