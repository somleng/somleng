require "rails_helper"

RSpec.describe "Admin/Tariff Schedules" do
 it "List tariff schedules" do
    carrier = create(:carrier)
    tariff_schedule = create(:tariff_schedule, carrier:)
    destination_tariff = create(:destination_tariff, schedule: tariff_schedule, carrier:)
    plan_tier = create(:tariff_plan_tier, schedule: tariff_schedule, carrier:)

    page.driver.browser.authorize("admin", "password")
    visit admin_tariff_schedules_path
    click_on(tariff_schedule.id)

    expect(page).to have_content(tariff_schedule.id)
    expect(page).to have_link(destination_tariff.tariff_id)
    expect(page).to have_link(plan_tier.id)

    click_on(destination_tariff.id)

    expect(page).to have_content(destination_tariff.id)

    click_on(destination_tariff.tariff_id)

    expect(page).to have_content(destination_tariff.tariff_id)
  end
end
