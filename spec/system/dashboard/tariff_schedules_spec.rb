require "rails_helper"

RSpec.describe "Tariff Schedules" do
  it "filter schedules" do
    carrier = create(:carrier)
    plan = create(:tariff_plan, carrier:)
    schedule = create(:tariff_schedule, category: plan.category, carrier:, name: "Standard")
    create(:tariff_plan_tier, schedule:, plan:)
    excluded_schedules = [
      create(:tariff_schedule, plan.category, carrier:, name: "Promo"),
      create(:tariff_schedule, :outbound_messages, carrier:, name: "Standard"),
      create(:tariff_schedule, plan.category, carrier:, name: "Standard 2")
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit(
      dashboard_tariff_schedules_path(
        filter: {
          name: "standard",
          category: "outbound_calls",
          tariff_plan_id: plan.id
        }
      )
    )

    expect(page).to have_content(schedule.id)
    excluded_schedules.each do |schedule|
      expect(page).to have_no_content(schedule.id)
    end
  end

  it "create a schedule", :js do
    carrier = create(:carrier, billing_currency: "USD")
    create(:destination_group, carrier:, name: "Cambodia")
    create(:destination_group, carrier:, name: "Cambodia Smart")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedules_path
    click_on("New")

    select("Outbound calls", from: "Category")
    fill_in("Name", with: "Standard")
    fill_in("Description", with: "My description")
    enhanced_select("Cambodia", from: "Destination group", exact: true)
    fill_in("Rate", with: "0.005")

    click_on("Add Tariff")

    expect(page).to have_destination_tariff_forms(count: 2)

    within(destination_tariff_forms.last) do
      fill_in("Rate", with: "0.003")
      enhanced_select("Cambodia Smart", from: "Destination group", exact: true)
    end

    click_on("Create Tariff schedule")

    expect(page).to have_content("Tariff schedule was successfully created.")
    expect(page).to have_content("Outbound calls")
    expect(page).to have_content("Standard")
    expect(page).to have_content("CALL -> Cambodia -> $0.005 / min and 1 more")

    expect(carrier.tariff_schedules.last).to have_attributes(
      description: "My description",
      destination_tariffs: contain_exactly(
        have_attributes(
          destination_group: have_attributes(
            name: "Cambodia"
          ),
          tariff: have_attributes(
            rate: InfinitePrecisionMoney.from_amount(0.005, "USD")
          )
        ),
        have_attributes(
          destination_group: have_attributes(
            name: "Cambodia Smart"
          ),
          tariff: have_attributes(
            rate: InfinitePrecisionMoney.from_amount(0.003, "USD")
          )
        )
      )
    )
  end

  it "preselects the inputs" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_schedule_path(
      filter: {
        category: :outbound_messages
      }
    )

    expect(page).to have_enhanced_select("Category", selected: "Outbound messages")
  end

  it "handle validation errors" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_schedule_path
    click_on("Create Tariff schedule")

    expect(page).to have_content("can't be blank")
  end

  it "show a schedule" do
    carrier = create(:carrier, billing_currency: "USD")
    schedule = create(:tariff_schedule, :outbound_messages, carrier:)
    plan = create(:tariff_plan, category: schedule.category, carrier:, name: "Standard")
    create(
      :destination_tariff,
      schedule:,
      destination_group: create(:destination_group, carrier:, name: "Cambodia"),
      tariff: create(:tariff, carrier:, rate_cents: 0.5)
    )
    create(
      :tariff_plan_tier,
      schedule:,
      plan:
    )
    create(
      :tariff_plan_tier,
      schedule:,
      plan: create(:tariff_plan, category: schedule.category, carrier:)
    )

    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_path(schedule)

    expect(page).to have_content("MSG -> Cambodia -> $0.005")
    expect(page).to have_link("Outbound messages (Standard)", href: dashboard_tariff_plan_path(plan))
    expect(page).to have_link("1 more", href: dashboard_tariff_plans_path(filter: { tariff_schedule_id: schedule.id }))
  end

  it "update a schedule", :js do
    carrier = create(:carrier, billing_currency: "USD")
    schedule = create(:tariff_schedule, :inbound_calls, carrier:, name: "Old Name", description: "Old Description")
    create(:destination_tariff, schedule:, destination_group: create(:destination_group, name: "Cambodia", carrier:))
    create(:destination_tariff, schedule:, destination_group: create(:destination_group, name: "Cambodia Smart", carrier:))
    create(:destination_group, name: "Cambodia Metfone", carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_path(schedule)
    click_on("Edit")

    expect(page).to have_content("Inbound calls")

    fill_in("Name", with: "New Name")
    fill_in("Description", with: "New Description")

    within(destination_tariff_forms.first) do
      click_on("Delete")
    end

    expect(page).to have_destination_tariff_forms(count: 1)

    click_on("Add Tariff")

    expect(page).to have_destination_tariff_forms(count: 2)

    within(destination_tariff_forms.last) do
      enhanced_select("Cambodia Metfone", from: "Destination group")
      fill_in("Rate", with: "0.005")
    end

    click_on("Update Tariff schedule")

    expect(page).to have_content("Tariff schedule was successfully updated.")
    expect(page).to have_content("New Name")
    expect(page).to have_content("New Description")
  end

  it "delete a schedule" do
    carrier = create(:carrier)
    schedule = create(:tariff_schedule, carrier:, name: "Standard")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_path(schedule)
    click_on("Delete")

    expect(page).to have_content("Tariff schedule was successfully destroyed.")
    expect(page).to have_no_content("Standard")
  end

  def destination_tariff_forms
    page.all('[data-test-id="destination-tariff-form"]')
  end

  def have_destination_tariff_forms(count:)
    have_css('[data-test-id="destination-tariff-form"]', count:)
  end
end
