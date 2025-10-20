require "rails_helper"

RSpec.describe "Destination Tariffs" do
  it "filters destination tariffs" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_schedule = create(:tariff_schedule, carrier:)
    destination_tariff = create(
      :destination_tariff,
      tariff_schedule:,
      tariff: create(:tariff, :call, carrier:, name: "Standard", per_minute_rate: Money.from_amount(0.01, "USD")),
      destination_group: create(:destination_group, carrier:)
    )

    filtered_destination_tariffs = [
      create(
        :destination_tariff,
        tariff_schedule: create(:tariff_schedule, carrier:),
        tariff: create(:tariff, :call, carrier:)
      ),
      create(
        :destination_tariff,
        tariff_schedule:,
        tariff: create(:tariff, :message, carrier:),
      ),
      create(:destination_tariff, tariff_schedule:, tariff: destination_tariff.tariff),
      create(:destination_tariff, tariff_schedule:, destination_group: destination_tariff.destination_group)
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_tariffs_path(
      filter: {
        category: "call",
        tariff_schedule_id: tariff_schedule.id,
        tariff_id: destination_tariff.tariff_id,
        destination_group_id: destination_tariff.destination_group_id
      }
    )

    expect(page).to have_content(destination_tariff.id)
    expect(page).to have_content("Standard ($0.01 per minute)")
    filtered_destination_tariffs.each do |destination_tariff|
      expect(page).to have_no_content(destination_tariff.id)
    end
  end

  it "create a destination tariff" do
    carrier = create(:carrier, billing_currency: "USD")
    create(:tariff_schedule, carrier:, name: "Default")
    create(:tariff, :call, carrier:, name: "Asia", per_minute_rate: Money.from_amount(0.01, "USD"))
    create(:destination_group, carrier:, name: "Cambodia")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_tariffs_path
    click_on("New")
    choices_select("Default", from: "Schedule")
    choices_select("Asia", from: "Tariff")
    choices_select("Cambodia", from: "Destination group")
    click_on("Create Destination tariff")

    expect(page).to have_content("Destination tariff was successfully created.")
    expect(page).to have_link("Default")
    expect(page).to have_link("Asia ($0.01 per minute)")
    expect(page).to have_link("Cambodia")
  end

  it "preselects the inputs" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_schedule = create(:tariff_schedule, carrier:, name: "Default")
    tariff = create(:tariff, :call, carrier:, name: "Asia", per_minute_rate: Money.from_amount(0.01, "USD"))
    destination_group = create(:destination_group, carrier:, name: "Cambodia")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_tariffs_path(
      filter: {
        tariff_schedule_id: tariff_schedule.id,
        tariff_id: tariff.id,
        destination_group_id: destination_group.id
      }
    )
    click_on("New")

    expect(page).to have_choices_select("Schedule", selected: "Default")
    expect(page).to have_choices_select("Tariff", selected: "Asia ($0.01 per minute)")
    expect(page).to have_choices_select("Destination group", selected: "Cambodia")
  end

  it "handles form validations" do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_destination_tariff_path
    click_on("Create Destination tariff")

    expect(page).to have_content("can't be blank")
  end

  it "show a destination tariff" do
    carrier = create(:carrier, billing_currency: "USD")
    destination_tariff = create(
      :destination_tariff,
      carrier:,
      tariff_schedule: create(:tariff_schedule, carrier:, name: "Standard"),
      tariff: create(:tariff, :call, carrier:, name: "Default", per_minute_rate: Money.from_amount(0.01, "USD")),
      destination_group: create(:destination_group, carrier:, name: "Cambodia")
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_tariff_path(destination_tariff)

    expect(page).to have_content("Call")
    expect(page).to have_link("Standard", href: dashboard_tariff_schedule_path(destination_tariff.tariff_schedule_id))
    expect(page).to have_link("Default ($0.01 per minute)", href: dashboard_tariff_path(destination_tariff.tariff_id))
    expect(page).to have_link("Cambodia", href: dashboard_destination_group_path(destination_tariff.destination_group_id))
  end

  it "delete a destination tariff" do
    carrier = create(:carrier)
    destination_tariff = create(:destination_tariff, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_tariff_path(destination_tariff)
    click_on("Delete")

    expect(page).to have_content("Destination tariff was successfully destroyed.")
    expect(page).to have_no_content(destination_tariff.id)
  end
end
