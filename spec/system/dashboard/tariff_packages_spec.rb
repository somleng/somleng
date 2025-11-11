require "rails_helper"

RSpec.describe "Tariff Packages" do
  it "filter tariff packages" do
    carrier = create(:carrier)
    tariff_package = create(:tariff_package, :outbound_calls, carrier:, name: "Discount")
    excluded_tariff_packages = [
      create(:tariff_package, :outbound_calls, carrier:, name: "Special"),
      create(:tariff_package, :outbound_messages, carrier:, name: "Discount")
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_packages_path(filter: { name: "discount", category: "outbound_calls" })

    expect(page).to have_content(tariff_package.id)
    excluded_tariff_packages.each do |tariff_package|
      expect(page).to have_no_content(tariff_package.id)
    end
  end

  it "create a tariff package", :js do
    carrier = create(:carrier)
    tariff_schedules = [
      create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard"),
      create(:tariff_schedule, :outbound_calls, carrier:, name: "Discount")
    ]

    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_packages_path
    click_on("New")

    fill_in("Name", with: "Discount")
    fill_in("Description", with: "My description")
    enhanced_select("Outbound calls", from: "Category")
    enhanced_select("Outbound calls (Discount)", from: "Tariff schedule")
    fill_in("Weight", with: "15")

    click_on("Add Tier")

    expect(page).to have_tariff_plan_tier_forms(count: 2)

    within(tariff_plan_tier_forms.last) do
      enhanced_select("Outbound calls (Standard)", from: "Tariff schedule")
      fill_in("Weight", with: "10")
    end

    click_on("Create Tariff package")

    expect(page).to have_content("Tariff package was successfully created.")
    expect(page).to have_link("Outbound calls (Discount)", href: dashboard_tariff_schedule_path(tariff_schedules[1]))
    expect(page).to have_link("1 more", href: dashboard_tariff_schedules_path(filter: { tariff_package_id: carrier.tariff_packages.last.id }))
    expect(carrier.tariff_packages.last).to have_attributes(
      name: "Discount",
      description: "My description",
      tiers: contain_exactly(
        have_attributes(
          schedule: have_attributes(
            name: "Discount"
          ),
          weight: 15
        ),
        have_attributes(
          schedule: have_attributes(
            name: "Standard"
          ),
          weight: 10
        )
      )
    )
  end

  it "preselects the inputs" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_package_path(filter: { category: "inbound_messages" })

    expect(page).to have_enhanced_select("Category", selected: "Inbound messages")
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
    tariff_package = create(:tariff_package, :outbound_calls, carrier:, name: "Standard", description: "My description")
    tariff_schedule = create(:tariff_schedule, :outbound_calls, name: "Standard", carrier:)
    create(
      :tariff_plan_tier,
      package: tariff_package,
      schedule: tariff_schedule
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(tariff_package)

    expect(page).to have_link("Manage", href: dashboard_tariff_bundles_path(filter: { tariff_package_id: tariff_package.id }))
    expect(page).to have_link("Standard", href: dashboard_tariff_schedule_path(tariff_schedule))
    expect(page).to have_content("My description")
  end

  it "update a tariff package", :js do
    carrier = create(:carrier)
    tariff_package = create(:tariff_package, :outbound_calls, carrier:, name: "Old Name", description: "Old Description")
    create(:tariff_plan_tier, package: tariff_package, schedule: create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard"), weight: 10)
    create(:tariff_plan_tier, package: tariff_package, schedule: create(:tariff_schedule, :outbound_calls, carrier:, name: "Discount"), weight: 15)
    create(:tariff_plan_tier, package: tariff_package, schedule: create(:tariff_schedule, :outbound_calls, carrier:, name: "VIP"), weight: 20)
    new_tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:, name: "New VIP")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(tariff_package)
    click_on("Edit")

    expect(page).to have_content("Outbound calls")

    fill_in("Name", with: "My VIP Package")
    fill_in("Description", with: "New Description")

    within(tariff_plan_tier_forms.first) do
      expect(page).to have_content("Outbound calls (VIP)")
      click_on("Delete")
    end

    expect(page).to have_tariff_plan_tier_forms(count: 2)

    click_on("Add Tier")

    expect(page).to have_tariff_plan_tier_forms(count: 3)

    within(tariff_plan_tier_forms.last) do
      enhanced_select("Outbound calls (New VIP)", from: "Tariff schedule")
      fill_in("Weight", with: "21")
    end

    within(tariff_plan_tier_forms.first) do
      expect(page).to have_content("Outbound calls (Discount)")
      fill_in("Weight", with: "16")
    end

    click_on("Update Tariff package")

    expect(page).to have_content("Tariff package was successfully updated.")
    expect(page).to have_content("My VIP Package")
    expect(page).to have_content("New Description")
    expect(page).to have_link("Outbound calls (New VIP)", href: dashboard_tariff_schedule_path(new_tariff_schedule))
    expect(page).to have_link("2 more", href: dashboard_tariff_schedules_path(filter: { tariff_package_id: tariff_package }))
    expect(tariff_package.reload).to have_attributes(
      name: "My VIP Package",
      description: "New Description",
      tiers: contain_exactly(
        have_attributes(
          schedule: have_attributes(
            name: "New VIP"
          ),
          weight: 21
        ),
        have_attributes(
          schedule: have_attributes(
            name: "Discount"
          ),
          weight: 16
        ),
        have_attributes(
          schedule: have_attributes(
            name: "Standard"
          ),
          weight: 10
        )
      )
    )
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

  it "calculate a tariff" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_schedule = create(:tariff_schedule, carrier:)
    destination_tariff = create(
      :destination_tariff,
      destination_group: create(:destination_group, carrier:, name: "KH Smart", prefixes: [ "85510" ]),
      tariff: create(:tariff, :call, carrier:, rate_cents: Money.from_amount(0.05, "USD").cents),
      tariff_schedule:
    )
    tariff_package = create(:tariff_package, carrier:)
    create(:tariff_plan_tier, package: tariff_package, schedule: tariff_schedule)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(tariff_package)

    fill_in("Destination", with: "85510233444")
    click_on("Calculate Tariff")

    expect(page).to have_link("CALL", href: dashboard_tariff_schedule_path(tariff_schedule))
    expect(page).to have_link("KH Smart", href: dashboard_destination_group_path(destination_tariff.destination_group))
    expect(page).to have_content("$0.05 / min")
  end

  it "handles errors when calculating a tariff" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_package = create(:tariff_package, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_package_path(tariff_package)

    fill_in("Destination", with: "855")
    click_on("Calculate Tariff")

    expect(page).to have_content("No tariff found for 855")
  end

  def tariff_plan_tier_forms
    page.all('[data-test-id="tariff-plan-tier-form"]')
  end

  def have_tariff_plan_tier_forms(count:)
    have_css('[data-test-id="tariff-plan-tier-form"]', count:)
  end
end
