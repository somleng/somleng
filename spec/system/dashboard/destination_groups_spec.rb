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
    expect(page).to have_content("85510, 85515, 85516")
    expect(page).to have_content("Metfone Cambodia")
    expect(page).to have_content("85597, 85571")
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
    expect(page).to have_content("85510, 85515, 85516")
  end

  it "handle validation errors when creating a destination group" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_destination_group_path

    click_on("Create Destination group")

    expect(page).to have_content("can't be blank")
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
    expect(page).to have_content("85510, 85515, 85516")
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
