require "rails_helper"

RSpec.describe "Signup" do
  it "Sign up as a carrier" do
    visit(new_user_registration_path)
    fill_in("Name", with: "John Doe")
    fill_in("Work email", with: "johndoe@att.com")
    fill_in("Company", with: "AT&T")
    fill_in("Subdomain", with: "at-t")
    select("Indonesia", from: "Country")
    fill_in("Website", with: "https://www.att.com")
    fill_in("Password", with: "Super Secret", match: :prefer_exact)
    fill_in("Password confirmation", with: "Super Secret")

    perform_enqueued_jobs do
      click_button("Sign up")
    end
    expect(page.current_url).to eq(new_user_session_url(subdomain: "at-t.app"))
    expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")

    open_email("johndoe@att.com")
    visit_full_link_in_email("Confirm my account")

    expect(page.current_url).to eq(new_user_session_url(subdomain: "at-t.app"))
    expect(page).to have_content("Your email address has been successfully confirmed.")
  end

  it "Handles validations" do
    visit(new_user_registration_path)

    click_button("Sign up")

    expect(page).to have_content("Name can't be blank")
  end
end
