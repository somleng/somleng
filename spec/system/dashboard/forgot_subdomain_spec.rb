require "rails_helper"

RSpec.describe "Forgot subdomain" do
  it "Handles forgotten subdomains" do
    carrier = create(:carrier, name: "AT&T", subdomain: "at-t")
    user = create(:user, :carrier, carrier:, email: "johndoe@att.com")

    visit(new_forgot_subdomain_path)
    fill_in("Email", with: user.email)

    perform_enqueued_jobs do
      click_button("Send me login instructions")
    end

    expect(page).to have_content("You will receive an email with login instructions in a few minutes")

    open_email("johndoe@att.com")
    visit_full_link_in_email("AT&T")

    expect(page.current_url).to eq(new_user_session_url(subdomain: "at-t.app"))
  end
end
