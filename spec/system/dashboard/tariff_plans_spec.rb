require "rails_helper"

RSpec.describe "Tariff Plans" do
  it "filters tariff plans" do
    carrier = create(:carrier)
    tariff_plan = create(:tariff_plan, :outbound_calls, carrier:)

    filtered_tariff_plans = [
      create(
        :tariff_plan,
        tariff_package: tariff_plan.tariff_package,
        tariff_schedule: create(:tariff_schedule, carrier:)
      ),
      create(
        :tariff_plan,
        tariff_package: create(:tariff_package, carrier:),
        tariff_schedule: tariff_plan.tariff_schedule
      )
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_plans_path(
      filter: {
        tariff_package_id: tariff_plan.tariff_package_id,
        tariff_schedule_id: tariff_plan.tariff_schedule_id,
        category: tariff_plan.tariff_package.category
      }
    )

    expect(page).to have_content(tariff_plan.id)
    filtered_tariff_plans.each do |tariff_plan|
      expect(page).to have_no_content(tariff_plan.id)
    end
  end

  it "disables the new link when there is no tariff package selected" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_plans_path

    expect(page).to have_link("New")
    expect(page.find_link("New")[:class]).to include("disabled")
  end

  it "create a tariff plan" do
    carrier = create(:carrier)
    tariff_package = create(:tariff_package, :outbound_calls, carrier:, name: "Discount")
    tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_plans_path(filter: { tariff_package_id: tariff_package.id })
    click_on("New")
    choices_select("Standard", from: "Schedule")
    click_on("Create Tariff plan")

    expect(page).to have_content("Tariff plan was successfully created.")
    expect(page).to have_link("Discount", href: dashboard_tariff_package_path(tariff_package))
    expect(page).to have_link("Standard", href: dashboard_tariff_schedule_path(tariff_schedule))
  end

  it "preselects the inputs" do
    carrier = create(:carrier)
    tariff_package = create(:tariff_package, :outbound_calls, carrier:, name: "Discount")
    tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_plans_path(
      filter: {
        tariff_package_id: tariff_package.id,
        tariff_schedule_id: tariff_schedule.id
      }
    )
    click_on("New")

    expect(page).to have_choices_select("Package", selected: "Outbound calls (Discount)", disabled: true)
    expect(page).to have_choices_select("Schedule", selected: "Outbound calls (Standard)")
  end

  it "handles form validations" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    tariff_package = create(:tariff_package, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_tariff_plan_path(filter: { tariff_package_id: tariff_package.id })
    click_on("Create Tariff plan")

    expect(page).to have_content("can't be blank")
  end

  it "show a tariff plan" do
    carrier = create(:carrier)
    tariff_plan = create(
      :tariff_plan,
      carrier:,
      tariff_package: create(:tariff_package, :outbound_calls, carrier:, name: "Discount"),
      tariff_schedule: create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard")
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_plan_path(tariff_plan)

    expect(page).to have_link("Outbound calls (Discount)", href: dashboard_tariff_package_path(tariff_plan.tariff_package_id))
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_schedule_path(tariff_plan.tariff_schedule_id))
  end

  it "delete a tariff plan" do
    carrier = create(:carrier)
    tariff_plan = create(:tariff_plan, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_plan_path(tariff_plan)
    click_on("Delete")

    expect(page).to have_content("Tariff plan was successfully destroyed.")
    expect(page).to have_no_content(tariff_plan.id)
  end
end
