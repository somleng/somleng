require "rails_helper"

RSpec.describe "Admin/Error Logs" do
  it "List error logs" do
    carrier = create(:carrier)
    create(:error_log, error_message: "SIP trunk does not exist for 175.100.7.240")
    error_log = create(:error_log, carrier:, error_message: "Phone number 1234 does not exist")
    create(:error_log_notification, error_log:)

    page.driver.browser.authorize("admin", "password")
    visit admin_error_logs_path

    expect(page).to have_content("SIP trunk does not exist for 175.100.7.240")
    expect(page).to have_content("Phone number 1234 does not exist")
  end
end
