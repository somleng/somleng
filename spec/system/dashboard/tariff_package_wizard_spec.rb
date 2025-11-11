require "rails_helper"

RSpec.describe "Tariff Package Wizard" do
  it "create a new tariff package via the wizard" do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit(dashboard_tariff_packages_path)
    click_on("Wizard")

    fill_in("Name", with: "Standard")
    within(".outbound-calls") do
      fill_in("Rate", with: "0.05")
    end
    within(".inbound-calls") do
      fill_in("Rate", with: "0.01")
    end
    within(".outbound-messages") do
      fill_in("Rate", with: "0.03")
    end
    within(".inbound-messages") do
      fill_in("Rate", with: "0.005")
    end

    click_on("Create Tariff package")

    expect(page).to have_content("Tariff package was successfully created.")
  end

  it "handles form validations" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit(new_dashboard_tariff_package_wizard_path)

    click_on("Create Tariff package")

    expect(page).to have_content("can't be blank")
  end
end
