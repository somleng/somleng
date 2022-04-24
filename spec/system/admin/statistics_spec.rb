require "rails_helper"

RSpec.describe "Admin/Statistics" do
  it "Show statistics" do
    carrier = create(:carrier, country_code: "US")
    create(:carrier, country_code: "MX")
    account = create(:account, carrier:)

    create_phone_call_interaction(phone_call_params: { account:, carrier:, to: "855715900760" })
    create_phone_call_interaction(phone_call_params: { account:, carrier:, to: "61438576076" })

    page.driver.browser.authorize("admin", "password")
    visit admin_statistics_path

    expect(page).to have_content("Beneficiaries: 2")
    expect(page).to have_content("Cambodia")
    expect(page).to have_content("Australia")
    expect(page).to have_content("United States")
    expect(page).to have_content("Mexico")
    expect(page).to have_content("Carriers: 2")
    expect(page).to have_content("Accounts: 1")
  end

  def create_phone_call_interaction(phone_call_params: {}, **params)
    phone_call = create(:phone_call, :outbound, phone_call_params)
    CreateInteraction.call(
      interactable: phone_call,
      beneficiary_fingerprint: phone_call.to,
      **params
    )
  end
end
