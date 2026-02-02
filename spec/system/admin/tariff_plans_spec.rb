require "rails_helper"

RSpec.describe "Admin/Tariff Plans" do
 it "List tariff plans" do
    carrier = create(:carrier)
    plan = create(:tariff_plan, name: "Standard", carrier:)
    plan_tier = create(:tariff_plan_tier, plan:, carrier:)

    page.driver.browser.authorize("admin", "password")
    visit admin_tariff_plans_path
    click_on(plan_tier.plan_id)

    expect(page).to have_content("Standard")
  end
end
