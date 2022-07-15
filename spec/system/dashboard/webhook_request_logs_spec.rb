require "rails_helper"

RSpec.describe "Webhook Request Logs" do
  it "List webhook request logs" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    event = create(:event, carrier:)
    webhook1 = create(:webhook_request_log, event:, failed: true)
    webhook2 = create(:webhook_request_log, event:, failed: false)
    webhook3 = create(:webhook_request_log, carrier:, failed: true)
    webhook4 = create(:webhook_request_log)

    carrier_sign_in(user)
    visit dashboard_webhook_request_logs_path(filter: { failed: true, event_id: event.id })

    expect(page).to have_content(webhook1.id)
    expect(page).to have_no_content(webhook2.id)
    expect(page).to have_no_content(webhook3.id)
    expect(page).to have_no_content(webhook4.id)
  end

  it "Shows a webhook request log" do
    webhook_request_log = create(:webhook_request_log)
    user = create(:user, :carrier, carrier: webhook_request_log.carrier)

    carrier_sign_in(user)
    visit dashboard_webhook_request_log_path(webhook_request_log)

    expect(page).to have_content(webhook_request_log.id)
  end
end
