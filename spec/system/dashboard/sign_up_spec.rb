require "rails_helper"

RSpec.describe "Signup" do
  it "Sign up as a carrier" do
    visit(new_user_registration_path)
    fill_in("Your name", with: "John Doe")
    fill_in("Work email", with: "johndoe@att.com")
    fill_in("Company", with: "AT&T")
    fill_in("Subdomain", with: "at-t")
    enhanced_select("Indonesia", from: "Country")
    enhanced_select("Indonesian Rupiah", from: "Billing currency")
    fill_in("Website", with: "https://www.att.com")
    fill_in("Password", with: "Super Secret", match: :prefer_exact)
    fill_in("Password confirmation", with: "Super Secret")

    stub_rating_engine_request
    perform_enqueued_jobs do
      click_on("Sign up")
    end

    expect(page.current_host).to eq("http://at-t.app.lvh.me")
    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")

    open_email("johndoe@att.com")
    visit_full_link_in_email("Confirm my account")

    expect(page.current_host).to eq("http://at-t.app.lvh.me")
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("Your email address has been successfully confirmed.")
  end

  it "Handles captcha", :js, :allow_net_connect, :captcha do
    stub_app_settings(recaptcha_minimum_score: 1)
    visit(new_user_registration_path)
    fill_in("Your name", with: "John Doe")
    fill_in("Work email", with: "johndoe@att.com")
    fill_in("Company", with: "AT&T")
    fill_in("Subdomain", with: "at-t")
    enhanced_select("United States", from: "Country")
    enhanced_select("United States Dollar", from: "Billing currency")
    fill_in("Website", with: "https://www.att.com")
    fill_in("Password", with: "Super Secret", match: :prefer_exact)
    fill_in("Password confirmation", with: "Super Secret")

    click_on("Sign up")

    expect(page).to have_field("Your name", with: "John Doe")
    expect(page).to have_xpath("//iframe[@title='reCAPTCHA']")
  end

  it "Handles validations" do
    visit(new_user_registration_path)

    click_on("Sign up")

    expect(page).to have_content("Name can't be blank")
  end
end
