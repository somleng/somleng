require "rails_helper"

RSpec.describe "Tariff Packages" do
  it "filter tariff packages" do
    carrier = create(:carrier)
    tariff_package = create(:tariff_package, :outbound_calls, carrier:, name: "Discount")
    filtered_tariff_packages = [
      create(:tariff_package, :outbound_calls, carrier:, name: "Special"),
      create(:tariff_package, :outbound_messages, carrier:, name: "Discount")
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_packages_path(filter: { name: "discount", category: "outbound_calls" })

    expect(page).to have_content(tariff_package.id)
    filtered_tariff_packages.each do |tariff_package|
      expect(page).to have_no_content(tariff_package.id)
    end
  end

  it "create a tariff package" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_packages_path
    click_on("New")

    select("Outbound calls", from: "Category")
    fill_in("Name", with: "Standard")
    fill_in("Description", with: "My package description")
    click_on("Create Tariff package")

    expect(page).to have_content("Tariff package was successfully created.")
    expect(page).to have_content("Outbound calls")
    expect(page).to have_content("My package description")
  end

  it "handle validation errors" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_package_path

    click_on("Create Tariff package")

    expect(page).to have_content("can't be blank")
  end

  it "show a tariff package" do
    carrier = create(:carrier)
    tariff_package = create(:tariff_package, carrier:, name: "Standard", description: "My package description")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(tariff_package)

    expect(page).to have_link("Manage", href: dashboard_tariff_plans_path(filter: { tariff_package_id: tariff_package.id }))
    expect(page).to have_content("Standard")
    expect(page).to have_content("My package description")
  end

  it "update a tariff package" do
    carrier = create(:carrier)
    tariff_package = create(:tariff_package, :inbound_calls, carrier:, name: "Old Name", description: "Old Description")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(tariff_package)
    click_on("Edit")

    expect(page).to have_content("Inbound calls")

    fill_in("Name", with: "My package name")
    fill_in("Description", with: "My package description")
    click_on("Update Tariff package")

    expect(page).to have_content("Tariff package was successfully updated.")
    expect(page).to have_content("My package name")
    expect(page).to have_content("My package description")
  end

  it "delete a tariff package" do
    carrier = create(:carrier)
    tariff_package = create(:tariff_package, carrier:, name: "Standard")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(tariff_package)
    click_on("Delete")

    expect(page).to have_content("Tariff package was successfully destroyed.")
    expect(page).to have_no_content("Standard")
  end
end
