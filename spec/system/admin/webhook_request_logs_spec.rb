require "rails_helper"

RSpec.describe "Admin / Webhook Request Logs" do
  it "List webhook request logs" do
    webhook_reqeust_log = create(:webhook_request_log)

    page.driver.browser.authorize("admin", "password")
    visit admin_webhook_request_logs_path

    expect(page).to have_content(webhook_reqeust_log.url)
  end
end
