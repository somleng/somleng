require "rails_helper"

RSpec.describe "Tariff Bundle Wizard" do
  it "create a new tariff bundle via the wizard" do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit(new_dashboard_tariff_bundle_wizard_path)

    fill_in("Name", with: "Standard")

    within(".outbound-messages") do
      fill_in("Rate", with: "0.05")
    end
  end
end
