require "rails_helper"

RSpec.describe "Tariff Bundles" do
  it "filter tariff bundles" do
    carrier = create(:carrier)
    tariff_bundle = create(:tariff_bundle, carrier:, name: "Standard")
    filtered_tariff_bundles = [
      create(:tariff_bundle, carrier:, name: "Special")
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundles_path(filter: { name: "standard" })

    expect(page).to have_content(tariff_bundle.id)
    filtered_tariff_bundles.each do |tariff_bundle|
      expect(page).to have_no_content(tariff_bundle.id)
    end
  end

  it "create a tariff bundle" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundles_path
    click_on("New")

    fill_in("Name", with: "My Bundle")
    fill_in("Description", with: "My bundle description")
    click_on("Create Tariff bundle")

    expect(page).to have_content("Tariff bundle was successfully created.")
    expect(page).to have_content("My Bundle")
    expect(page).to have_content("My bundle description")
  end

  it "handle validation errors" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_bundle_path

    click_on("Create Tariff bundle")

    expect(page).to have_content("can't be blank")
  end

  it "show a tariff bundle" do
    carrier = create(:carrier)
    tariff_bundle = create(:tariff_bundle, carrier:, name: "Standard", description: "My bundle description")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundle_path(tariff_bundle)

    expect(page).to have_content("Standard")
    expect(page).to have_content("My bundle description")
  end

  it "update a tariff package" do
    carrier = create(:carrier)
    tariff_bundle= create(:tariff_bundle, carrier:, name: "Old Name", description: "Old Description")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundle_path(tariff_bundle)
    click_on("Edit")

    fill_in("Name", with: "My bundle name")
    fill_in("Description", with: "My bundle description")
    click_on("Update Tariff bundle")

    expect(page).to have_content("Tariff bundle was successfully updated.")
    expect(page).to have_content("My bundle name")
    expect(page).to have_content("My bundle description")
  end

  it "delete a tariff package" do
    carrier = create(:carrier)
    tariff_bundle = create(:tariff_bundle, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundle_path(tariff_bundle)
    click_on("Delete")

    expect(page).to have_content("Tariff bundle was successfully destroyed.")
    expect(page).to have_no_content(tariff_bundle.id)
  end
end
