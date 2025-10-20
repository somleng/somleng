require "rails_helper"

RSpec.describe "Tariff Schedules" do
  it "filter tariff schedules" do
    carrier = create(:carrier)
    standard_schedule = create(:tariff_schedule, carrier:, name: "Standard")
    discounted_schedule = create(:tariff_schedule, carrier:, name: "Discounted")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedules_path(filter: { name: "standard" })

    expect(page).to have_content(standard_schedule.id)
    expect(page).to have_no_content(discounted_schedule.id)
  end

  it "create a tariff schedule" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedules_path
    click_on("New")

    fill_in("Name", with: "Standard")
    fill_in("Description", with: "Standard rates")
    click_on("Create Tariff schedule")

    expect(page).to have_content("Tariff schedule was successfully created.")
    expect(page).to have_content("Standard")
    expect(page).to have_content("Standard rates")
  end

  it "handle validation errors" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_schedule_path

    click_on("Create Tariff schedule")

    expect(page).to have_content("can't be blank")
  end

  it "show a tariff schedule" do
    carrier = create(:carrier)
    tariff_schedule = create(:tariff_schedule, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_path(tariff_schedule)

    expect(page).to have_link("Manage", href: dashboard_destination_tariffs_path(filter: { tariff_schedule_id: tariff_schedule.id }))
  end

  it "update a tariff schedule" do
    carrier = create(:carrier)
    tariff_schedule = create(:tariff_schedule, carrier:, name: "Old Name", description: "Old Description")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_path(tariff_schedule)
    click_on("Edit")
    fill_in("Name", with: "New Name")
    fill_in("Description", with: "Standard rates")
    click_on("Update Tariff schedule")

    expect(page).to have_content("Tariff schedule was successfully updated.")
    expect(page).to have_content("New Name")
    expect(page).to have_content("Standard rates")
  end

  it "delete a tariff schedule" do
    carrier = create(:carrier)
    tariff_schedule = create(:tariff_schedule, carrier:, name: "Standard")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_path(tariff_schedule)
    click_on("Delete")

    expect(page).to have_content("Tariff schedule was successfully destroyed.")
    expect(page).to have_no_content("Standard")
  end
end
