require "rails_helper"

RSpec.describe "Admin/Statistics" do
  it "Show statistics" do
    carrier = create(:carrier, country_code: "US")
    create(:carrier, country_code: "MX")
    account = create(:account, carrier:)

    create_phone_call_interaction(phone_call_params: { account:, carrier:, to: "855715900760" })
    create_phone_call_interaction(phone_call_params: { account:, carrier:, to: "61438576076" })
    create(:interaction, interactable: create(:message, :robot, account:, carrier:))

    page.driver.browser.authorize("admin", "password")
    visit admin_statistics_path

    expect(page).to have_link("last_quarter")
    expect(page).to have_link("last_year")
    expect(page).to have_text("Beneficiaries: 2")
    expect(page).to have_text("Interactions: 3")
    expect(page).to have_text("Cambodia")
    expect(page).to have_text("Australia")
    expect(page).to have_text("United States")
    expect(page).to have_text("Mexico")
    expect(page).to have_text("Carriers: 2")
    expect(page).to have_text("Accounts: 1")
    expect(page).to have_text("Phone Calls: 2")
    expect(page).to have_text("Bill Minutes")
    expect(page).to have_text("TTS Characters")
  end

  def create_phone_call_interaction(phone_call_params: {}, **)
    phone_call = create(:phone_call, :outbound, :completed, phone_call_params)
    create(:interaction, interactable: phone_call, **)
  end
end
