require "rails_helper"

RSpec.describe "Error Logs" do
  it "List error logs" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    create(:error_log, :inbound_message, carrier:, error_message: "Phone number 1234 does not exist")
    create(:error_log, :inbound_call, carrier:, error_message: "Phone number 5678 is unconfigured")

    carrier_sign_in(user)
    visit(dashboard_error_logs_path)

    expect(page).to have_content("Phone number 1234 does not exist")
    expect(page).to have_content("Phone number 5678 is unconfigured")

    visit(dashboard_error_logs_path(filter: { type: :inbound_message }))

    expect(page).to have_content("Phone number 1234 does not exist")
    expect(page).to have_no_content("Phone number 5678 is unconfigured")
  end
end
