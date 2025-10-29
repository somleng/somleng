require "rails_helper"

RSpec.describe "Destination Tariffs" do
  it "filters destination tariffs" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_schedule = create(:tariff_schedule, carrier:)
    destination_tariff = create(
      :destination_tariff,
      tariff_schedule:,
      tariff: create(:tariff, :call, carrier:, per_minute_rate: Money.from_amount(0.01, "USD")),
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
    expect(page).to have_content("$0.01 / min")
    filtered_destination_tariffs.each do |destination_tariff|
      expect(page).to have_no_content(destination_tariff.id)
    end
  end

  it "disables the new link when there is no tariff schedule selected" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_tariffs_path

    expect(page).to have_link("New")
    expect(page.find_link("New")[:class]).to include("disabled")
  end

  it "create a destination tariff" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard")
    create(:tariff, :call, carrier:, per_minute_rate: Money.from_amount(0.01, "USD"))
    create(:tariff, :message, carrier:, name: "Standard Message")
    create(:destination_group, carrier:, name: "Cambodia")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_tariffs_path(filter: { tariff_schedule_id: tariff_schedule.id })
    click_on("New")
    choices_select("$0.01 / min", from: "Tariff")
    choices_select("Cambodia", from: "Destination group")
    click_on("Create Destination tariff")

    expect(page).to have_content("Destination tariff was successfully created.")
    expect(page).to have_link("Standard")
    expect(page).to have_link("$0.01 / min")
    expect(page).to have_link("Cambodia")
  end

  it "preselects the inputs" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard")
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

    expect(page).to have_choices_select("Tariff schedule", selected: "Outbound calls (Standard)", disabled: true)
    expect(page).to have_choices_select("Tariff", selected: "$0.01 / min (Asia)")
    expect(page).to have_choices_select("Destination group", selected: "Cambodia")
  end

  it "handles form validations" do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:)
    tariff_schedule = create(:tariff_schedule, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_destination_tariff_path(filter: { tariff_schedule_id: tariff_schedule.id })
    click_on("Create Destination tariff")

    expect(page).to have_content("can't be blank")
  end

  it "show a destination tariff" do
    carrier = create(:carrier, billing_currency: "USD")
    destination_tariff = create(
      :destination_tariff,
      carrier:,
      tariff_schedule: create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard"),
      tariff: create(:tariff, :call, carrier:, per_minute_rate: Money.from_amount(0.01, "USD")),
      destination_group: create(:destination_group, carrier:, name: "Cambodia")
    )
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_destination_tariff_path(destination_tariff)

    expect(page).to have_content("Call")
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_schedule_path(destination_tariff.tariff_schedule_id))
    expect(page).to have_link("$0.01 / min", href: dashboard_tariff_path(destination_tariff.tariff_id))
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
