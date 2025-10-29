require "rails_helper"

RSpec.describe "Tariff Bundles" do
  it "filter tariff bundles" do
    carrier = create(:carrier)
    tariff_bundle = create(:tariff_bundle, carrier:, name: "Standard")
    tariff_package = create(:tariff_package, carrier:)
    create(:tariff_bundle_line_item, tariff_bundle:, tariff_package:)
    filtered_tariff_bundles = [
      create(:tariff_bundle, carrier:, name: "Special"),
      create(:tariff_bundle, carrier:, name: "Standard")
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundles_path(filter: { name: "standard", tariff_package_id: tariff_package.id })

    expect(page).to have_content(tariff_bundle.id)
    filtered_tariff_bundles.each do |tariff_bundle|
      expect(page).to have_no_content(tariff_bundle.id)
    end
  end

  it "create a tariff bundle with all packages selected" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    outbound_messages_package = create(:tariff_package, :outbound_messages, carrier:, name: "Standard")
    inbound_messages_package = create(:tariff_package, :inbound_messages, carrier:, name: "Standard")
    outbound_calls_package = create(:tariff_package, :outbound_calls, carrier:, name: "Standard")
    inbound_calls_package = create(:tariff_package, :inbound_calls, carrier:, name: "Standard")

    carrier_sign_in(user)
    visit dashboard_tariff_bundles_path
    click_on("New")

    fill_in("Name", with: "My Bundle")
    fill_in("Description", with: "My bundle description")
    within(".outbound-messages-line-item") do
      choices_select("Outbound messages (Standard)", from: "Tariff package")
    end
    within(".inbound-messages-line-item") do
      choices_select("Inbound messages (Standard)", from: "Tariff package")
    end
    within(".outbound-calls-line-item") do
      choices_select("Outbound calls (Standard)", from: "Tariff package")
    end
    within(".inbound-calls-line-item") do
      choices_select("Inbound calls (Standard)", from: "Tariff package")
    end
    click_on("Create Tariff bundle")

    expect(page).to have_content("Tariff bundle was successfully created.")
    expect(page).to have_link("Outbound messages (Standard)", href: dashboard_tariff_package_path(outbound_messages_package))
    expect(page).to have_link("Inbound messages (Standard)", href: dashboard_tariff_package_path(inbound_messages_package))
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_package_path(outbound_calls_package))
    expect(page).to have_link("Inbound calls (Standard)", href: dashboard_tariff_package_path(inbound_calls_package))

    expect(page).to have_content("My Bundle")
    expect(page).to have_content("My bundle description")
  end

  it "create a tariff bundle with only some packages selected" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(:tariff_package, :outbound_calls, carrier:, name: "Standard")

    carrier_sign_in(user)
    visit dashboard_tariff_bundles_path
    click_on("New")

    fill_in("Name", with: "My Bundle")
    within(".outbound-calls-line-item") do
      choices_select("Outbound calls (Standard)", from: "Tariff package")
    end
    click_on("Create Tariff bundle")

    expect(page).to have_content("Tariff bundle was successfully created.")
    expect(page).to have_content("My Bundle")
  end

  it "handle validation errors when creating a tariff bundle" do
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

  it "update a tariff bundle" do
    carrier = create(:carrier)
    tariff_bundle = create(:tariff_bundle, carrier:, name: "Old Name", description: "Old Description")
    outbound_messages_package = create(:tariff_package, :outbound_messages, carrier:, name: "Standard")
    outbound_calls_package = create(:tariff_package, :outbound_calls, carrier:, name: "Standard")
    inbound_calls_package = create(:tariff_package, :inbound_calls, carrier:)
    create(:tariff_bundle_line_item, tariff_bundle:, tariff_package: outbound_calls_package)
    create(:tariff_bundle_line_item, tariff_bundle:, tariff_package: inbound_calls_package)

    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundle_path(tariff_bundle)
    click_on("Edit")

    fill_in("Name", with: "My bundle name")
    fill_in("Description", with: "My bundle description")
    within(".outbound-messages-line-item") do
      choices_select("Outbound messages (Standard)", from: "Tariff package")
    end
    within(".inbound-calls-line-item") do
      choices_select("", from: "Tariff package")
    end
    click_on("Update Tariff bundle")

    expect(page).to have_content("Tariff bundle was successfully updated.")
    expect(page).to have_content("My bundle name")
    expect(page).to have_content("My bundle description")
    expect(page).to have_link("Outbound messages (Standard)", href: dashboard_tariff_package_path(outbound_messages_package))
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_package_path(outbound_calls_package))
    expect(page).to have_no_link("Inbound calls (Standard)")
  end

  it "handle validation errors when updating a tariff bundle" do
    carrier = create(:carrier)
    tariff_bundle = create(:tariff_bundle, carrier:)
    create(:tariff_bundle_line_item, tariff_bundle:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit edit_dashboard_tariff_bundle_path(tariff_bundle)
    fill_in("Name", with: "")

    click_on("Update Tariff bundle")

    expect(page).to have_content("can't be blank")
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
