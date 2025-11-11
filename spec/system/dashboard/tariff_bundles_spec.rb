require "rails_helper"

RSpec.describe "Tariff Bundles" do
  it "filter tariff bundles" do
    carrier = create(:carrier)
    tariff_bundle = create(:tariff_bundle, carrier:, name: "Standard")
    tariff_plan = create(:tariff_plan, carrier:)
    create(:tariff_bundle_line_item, tariff_bundle:, tariff_plan:)
    filtered_tariff_bundles = [
      create(:tariff_bundle, carrier:, name: "Special"),
      create(:tariff_bundle, carrier:, name: "Standard")
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundles_path(filter: { name: "standard", tariff_plan_id: tariff_plan.id })

    expect(page).to have_content(tariff_bundle.id)
    filtered_tariff_bundles.each do |tariff_bundle|
      expect(page).to have_no_content(tariff_bundle.id)
    end
  end

  it "create a tariff bundle with all plans selected" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    outbound_messages_plan = create(:tariff_plan, :outbound_messages, carrier:, name: "Standard")
    inbound_messages_plan = create(:tariff_plan, :inbound_messages, carrier:, name: "Standard")
    outbound_calls_plan = create(:tariff_plan, :outbound_calls, carrier:, name: "Standard")
    inbound_calls_plan = create(:tariff_plan, :inbound_calls, carrier:, name: "Standard")

    carrier_sign_in(user)
    visit dashboard_tariff_bundles_path
    click_on("New")

    fill_in("Name", with: "My Bundle")
    fill_in("Description", with: "My bundle description")
    within(".outbound-messages-line-item") do
      enhanced_select("Outbound messages (Standard)", from: "Tariff plan")
    end
    within(".inbound-messages-line-item") do
      enhanced_select("Inbound messages (Standard)", from: "Tariff plan")
    end
    within(".outbound-calls-line-item") do
      enhanced_select("Outbound calls (Standard)", from: "Tariff plan")
    end
    within(".inbound-calls-line-item") do
      enhanced_select("Inbound calls (Standard)", from: "Tariff plan")
    end
    click_on("Create Tariff bundle")

    expect(page).to have_content("Tariff bundle was successfully created.")
    expect(page).to have_link("Outbound messages (Standard)", href: dashboard_tariff_plan_path(outbound_messages_plan))
    expect(page).to have_link("Inbound messages (Standard)", href: dashboard_tariff_plan_path(inbound_messages_plan))
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_plan_path(outbound_calls_plan))
    expect(page).to have_link("Inbound calls (Standard)", href: dashboard_tariff_plan_path(inbound_calls_plan))

    expect(page).to have_content("My Bundle")
    expect(page).to have_content("My bundle description")
  end

  it "create a tariff bundle with only some plans selected" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    create(:tariff_plan, :outbound_calls, carrier:, name: "Standard")

    carrier_sign_in(user)
    visit dashboard_tariff_bundles_path
    click_on("New")

    fill_in("Name", with: "My Bundle")
    within(".outbound-calls-line-item") do
      enhanced_select("Outbound calls (Standard)", from: "Tariff plan")
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
    outbound_messages_plan = create(:tariff_plan, :outbound_messages, carrier:, name: "Standard")
    outbound_calls_plan = create(:tariff_plan, :outbound_calls, carrier:, name: "Standard")
    inbound_calls_plan = create(:tariff_plan, :inbound_calls, carrier:)
    create(:tariff_bundle_line_item, tariff_bundle:, tariff_plan: outbound_calls_plan)
    create(:tariff_bundle_line_item, tariff_bundle:, tariff_plan: inbound_calls_plan)

    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_bundle_path(tariff_bundle)
    click_on("Edit")

    fill_in("Name", with: "My bundle name")
    fill_in("Description", with: "My bundle description")
    within(".outbound-messages-line-item") do
      enhanced_select("Outbound messages (Standard)", from: "Tariff plan")
    end
    within(".inbound-calls-line-item") do
      enhanced_select("", from: "Tariff plan")
    end
    click_on("Update Tariff bundle")

    expect(page).to have_content("Tariff bundle was successfully updated.")
    expect(page).to have_content("My bundle name")
    expect(page).to have_content("My bundle description")
    expect(page).to have_link("Outbound messages (Standard)", href: dashboard_tariff_plan_path(outbound_messages_plan))
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_plan_path(outbound_calls_plan))
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

  it "delete a tariff plan" do
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
