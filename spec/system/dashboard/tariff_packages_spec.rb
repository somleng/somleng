require "rails_helper"

RSpec.describe "Tariff Packages" do
  it "filter packages" do
    carrier = create(:carrier)
    package = create(:tariff_package, carrier:, name: "Standard 1")
    plan = create(:tariff_plan, carrier:)
    create(:tariff_package_plan, package:, plan:)
    excluded_packages = [
      create(:tariff_package, carrier:, name: "Special"),
      create(:tariff_package, carrier:, name: "Standard 2")
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_packages_path(filter: { name: "standard", tariff_plan_id: plan.id })

    expect(page).to have_content(package.id)
    excluded_packages.each do |package|
      expect(page).to have_no_content(package.id)
    end
  end

  it "create a package with all plans selected" do
    carrier = create(:carrier)
    outbound_messages_plan = create(:tariff_plan, :outbound_messages, carrier:, name: "Standard")
    inbound_messages_plan = create(:tariff_plan, :inbound_messages, carrier:, name: "Standard")
    outbound_calls_plan = create(:tariff_plan, :outbound_calls, carrier:, name: "Standard")
    inbound_calls_plan = create(:tariff_plan, :inbound_calls, carrier:, name: "Standard")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_packages_path
    click_on("New")

    fill_in("Name", with: "My Package")
    fill_in("Description", with: "My description")
    within(".outbound-messages-line-item") do
      enhanced_select("Outbound messages (Standard)", from: "Plan")
    end
    within(".inbound-messages-line-item") do
      enhanced_select("Inbound messages (Standard)", from: "Plan")
    end
    within(".outbound-calls-line-item") do
      enhanced_select("Outbound calls (Standard)", from: "Plan")
    end
    within(".inbound-calls-line-item") do
      enhanced_select("Inbound calls (Standard)", from: "Plan")
    end
    click_on("Create Tariff package")

    expect(page).to have_content("Tariff package was successfully created.")
    expect(page).to have_content("My Package")
    expect(page).to have_link("Outbound messages (Standard)", href: dashboard_tariff_plan_path(outbound_messages_plan))
    expect(page).to have_link("Inbound messages (Standard)", href: dashboard_tariff_plan_path(inbound_messages_plan))
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_plan_path(outbound_calls_plan))
    expect(page).to have_link("Inbound calls (Standard)", href: dashboard_tariff_plan_path(inbound_calls_plan))
  end

  it "create a package with only some plans selected" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(:tariff_plan, :outbound_calls, carrier:, name: "Standard")

    carrier_sign_in(user)
    visit dashboard_tariff_packages_path
    click_on("New")

    fill_in("Name", with: "My Package")
    within(".outbound-calls-line-item") do
      enhanced_select("Outbound calls (Standard)", from: "Plan")
    end
    click_on("Create Tariff package")

    expect(page).to have_content("Tariff package was successfully created.")
    expect(page).to have_content("My Package")
  end

  it "handle validation errors when creating a package" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_package_path

    click_on("Create Tariff package")

    expect(page).to have_content("can't be blank")
  end

  it "show a package" do
    carrier = create(:carrier)
    package = create(:tariff_package, carrier:, name: "Standard", description: "My package description")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(package)

    expect(page).to have_content("Standard")
    expect(page).to have_content("My package description")
  end

  it "update a package" do
    carrier = create(:carrier)
    package = create(:tariff_package, carrier:, name: "Old Name", description: "Old Description")
    outbound_messages_plan = create(:tariff_plan, :outbound_messages, carrier:, name: "Standard")
    outbound_calls_plan = create(:tariff_plan, :outbound_calls, carrier:, name: "Standard")
    inbound_calls_plan = create(:tariff_plan, :inbound_calls, carrier:)
    create(:tariff_package_plan, package:, plan: outbound_calls_plan)
    create(:tariff_package_plan, package:, plan: inbound_calls_plan)

    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(package)
    click_on("Edit")

    fill_in("Name", with: "My package name")
    fill_in("Description", with: "My package description")
    within(".outbound-messages-line-item") do
      enhanced_select("Outbound messages (Standard)", from: "Plan")
    end
    within(".inbound-calls-line-item") do
      enhanced_select("", from: "Plan")
    end
    click_on("Update Tariff package")

    expect(page).to have_content("Tariff package was successfully updated.")
    expect(page).to have_content("My package name")
    expect(page).to have_content("My package description")
    expect(page).to have_link("Outbound messages (Standard)", href: dashboard_tariff_plan_path(outbound_messages_plan))
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_plan_path(outbound_calls_plan))
    expect(page).to have_no_link("Inbound calls (Standard)")
  end

  it "handle validation errors when updating a package" do
    carrier = create(:carrier)
    package = create(:tariff_package, carrier:)
    create(:tariff_package_plan, package:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit edit_dashboard_tariff_package_path(package)
    fill_in("Name", with: "")

    click_on("Update Tariff package")

    expect(page).to have_content("can't be blank")
  end

  it "delete a package" do
    carrier = create(:carrier)
    package = create(:tariff_package, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(package)
    click_on("Delete")

    expect(page).to have_content("Tariff package was successfully destroyed.")
    expect(page).to have_no_content(package.id)
  end
end
