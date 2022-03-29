require "rails_helper"

RSpec.describe "Carrier Signup" do
  it "Sign in with OTP" do
    visit(new_user_registration_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    fill_in("OTP Code", with: user.current_otp)
    click_button("Login")

    expect(page).to have_content("Signed in successfully")
  end
end
