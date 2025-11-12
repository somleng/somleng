require "rails_helper"

RSpec.describe "Destination Groups" do
  it "filter destination groups" do
    carrier = create(:carrier)
    create(:destination_group, carrier:, name: "Smart Cambodia", prefixes: [ "85510", "85515", "85516" ])
    create(:destination_group, carrier:, name: "Metfone Cambodia", prefixes: [ "85597", "85571" ])
    create(:destination_group, carrier:, name: "Laos")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_groups_path(filter: { name: "Cambodia" })

    expect(page).to have_content("Smart Cambodia")
    expect(page).to have_content("85510, 85515, and 85516")
    expect(page).to have_content("Metfone Cambodia")
    expect(page).to have_content("85597 and 85571")
    expect(page).to have_no_content("Laos")
  end

  it "create a destination group" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_groups_path
    click_on("New")

    fill_in("Name", with: "Smart Cambodia")
    fill_in("Prefixes", with: "85510, 85515, 85516, 85516")
    click_on("Create Destination group")

    expect(page).to have_content("Destination group was successfully created.")
    expect(page).to have_content("Smart Cambodia")
    expect(page).to have_content("85510, 85515, and 85516")
  end

  it "create a catch all destination group", :js do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_destination_group_path
    check("Catch all")
    click_on("Create Destination group")

    expect(page).to have_content("Destination group was successfully created.")
    expect(page).to have_content("Catch all")
    expect(page).to have_content("0, 1, 2, and 7 more")
  end

  it "handle validation errors when creating a destination group" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_destination_group_path

    click_on("Create Destination group")

    expect(page).to have_content("can't be blank")
  end

  it "show a destination group" do
    carrier = create(:carrier)
    destination_group = create(:destination_group, carrier:)
    destination_tariff = create(
      :destination_tariff,
      destination_group:,
      schedule: create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard")
    )
    create(
      :destination_tariff,
      destination_group:,
      schedule: create(:tariff_schedule, :inbound_calls, carrier:)
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_group_path(destination_group)

    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_schedule_path(destination_tariff.schedule))
    expect(page).to have_link("1 more", href: dashboard_tariff_schedules_path(filter: { destination_group_id: destination_group.id }))
  end

  it "update a destination group" do
    carrier = create(:carrier)
    destination_group = create(:destination_group, carrier:, name: "US Destinations", prefixes: [ "1" ])
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_group_path(destination_group)
    click_on("Edit")

    fill_in("Name", with: "Smart Cambodia")
    fill_in("Prefixes", with: "85510, 85515, 85516")
    click_on("Update Destination group")

    expect(page).to have_content("Destination group was successfully updated.")
    expect(page).to have_content("Smart Cambodia")
    expect(page).to have_content("85510, 85515, and 85516")
  end

  it "delete a destination group" do
    carrier = create(:carrier)
    destination_group = create(:destination_group, carrier:, name: "US Cambodia", prefixes: [ "85510" ])
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_group_path(destination_group)
    click_on("Delete")

    expect(page).to have_content("Destination group was successfully destroyed.")
    expect(page).to have_no_content("Smart Cambodia")
  end
end
