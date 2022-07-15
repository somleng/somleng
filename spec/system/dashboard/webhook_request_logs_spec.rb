require "rails_helper"

RSpec.describe "Webhook Request Logs" do
  it "List webhook request logs" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    event = create(:event, carrier:)
    create(:webhook_request_log, event:, http_status_code: 500, failed: true)
    create(:webhook_request_log, event:, http_status_code: 200, failed: false)
    create(:webhook_request_log, carrier:, http_status_code: 404, failed: true)
    create(:webhook_request_log, http_status_code: 401)

    carrier_sign_in(user)
    visit dashboard_webhook_request_logs_path(filter: { failed: true, event_id: event.id })

    expect(page).to have_content("500")
    expect(page).to have_no_content("404")
    expect(page).to have_no_content("200")
    expect(page).to have_no_content("401")
  end

  it "Shows a webhook request log" do
    webhook_request_log = create(:webhook_request_log)
    user = create(:user, :carrier, carrier: webhook_request_log.carrier)

    carrier_sign_in(user)
    visit dashboard_webhook_request_log_path(webhook_request_log)

    expect(page).to have_content(webhook_request_log.id)
  end
end
