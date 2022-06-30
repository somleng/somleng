require "rails_helper"

RSpec.describe "Error Logs" do
  it "List error logs" do
    carrier = create(:carrier)
    other_carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    account = create(:account, carrier:)

    create(:error_log, carrier:, error_message: "Phone number 1234 does not exist")
    create(:error_log, carrier:, account:, error_message: "Phone number 5678 is unconfigured")
    create(:error_log, carrier: other_carrier, error_message: "other carrier")

    carrier_sign_in(user)
    visit dashboard_error_logs_path

    expect(page).to have_content("Phone number 1234 does not exist")
    expect(page).to have_content("Phone number 5678 is unconfigured")
    expect(page).to have_no_content("other carrier")
  end
end
