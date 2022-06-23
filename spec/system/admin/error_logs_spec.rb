require "rails_helper"

RSpec.describe "Admin/Error Logs" do
  it "List error logs" do
    carrier = create(:carrier)
    create(:error_log, error_message: "Inbound SIP trunk does not exist for 175.100.7.240")
    create(:error_log, carrier:, error_message: "Phone number 1234 does not exist")

    page.driver.browser.authorize("admin", "password")
    visit admin_error_logs_path

    expect(page).to have_content("Inbound SIP trunk does not exist for 175.100.7.240")
    expect(page).to have_content("Phone number 1234 does not exist")
  end
end
