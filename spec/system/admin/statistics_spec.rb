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

    expect(page).to have_link("pghero", href: admin_pg_hero_path)
    expect(page).to have_link("last_quarter")
    expect(page).to have_link("last_year")
    expect(page).to have_content("Beneficiaries: 2")
    expect(page).to have_content("Interactions: 3")
    expect(page).to have_content("Cambodia")
    expect(page).to have_content("Australia")
    expect(page).to have_content("United States")
    expect(page).to have_content("Mexico")
    expect(page).to have_content("Carriers: 2")
    expect(page).to have_content("Accounts: 1")
    expect(page).to have_content("Phone Calls: 2")
    expect(page).to have_content("Bill Minutes")
    expect(page).to have_content("TTS Characters")
  end

  def create_phone_call_interaction(phone_call_params: {}, **)
    phone_call = create(:phone_call, :outbound, :completed, phone_call_params)
    create(:interaction, interactable: phone_call, **)
  end
end
