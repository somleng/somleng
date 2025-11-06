require "rails_helper"

RSpec.describe "Destination Tariffs" do
  it "filter destination tariffs" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_schedule = create(:tariff_schedule, carrier:)
    destination_tariff = create(
      :destination_tariff,
      tariff_schedule:,
      tariff: create(:tariff, :call, carrier:, per_minute_rate: Money.from_amount(0.01, "USD")),
      destination_group: create(:destination_group, carrier:)
    )

    excluded_destination_tariffs = [
      create(
        :destination_tariff,
        tariff_schedule:,
        tariff: create(:tariff, :message, carrier:),
      )
    ]
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_destination_tariffs_path(
      tariff_schedule,
      filter: {
        destination_group_id: destination_tariff.destination_group_id
      }
    )

    expect(page).to have_content(destination_tariff.id)
    expect(page).to have_content("$0.01 / min")
    excluded_destination_tariffs.each do |destination_tariff|
      expect(page).to have_no_content(destination_tariff.id)
    end
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
    visit dashboard_tariff_schedule_destination_tariff_path(destination_tariff.tariff_schedule, destination_tariff)

    expect(page).to have_content("Call")
    expect(page).to have_link("Outbound calls (Standard)", href: dashboard_tariff_schedule_path(destination_tariff.tariff_schedule_id))
    expect(page).to have_link("Cambodia", href: dashboard_destination_group_path(destination_tariff.destination_group_id))
    expect(page).to have_content("$0.01 / min")
  end

  it "update a destination tariff" do
    carrier = create(:carrier, billing_currency: "USD")
    tariff_schedule = create(:tariff_schedule, carrier:)
    destination_group = create(:destination_group, carrier:, name: "Cambodia Smart", prefixes: [ "85510" ])
    destination_tariff = create(:destination_tariff, tariff_schedule:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_destination_tariff_path(tariff_schedule, destination_tariff)
    click_on("Edit")

    enhanced_select("Cambodia Smart", from: "Destination group")
    fill_in("Rate", with: "0.003")
    click_on("Update Destination tariff")

    expect(page).to have_content("Destination tariff was successfully updated.")
    expect(page).to have_link("Cambodia Smart", href: dashboard_destination_group_path(destination_group))
    expect(page).to have_content("$0.003 / min")
  end

  it "delete a destination tariff" do
    carrier = create(:carrier)
    destination_tariff = create(:destination_tariff, carrier:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_tariff_schedule_destination_tariff_path(destination_tariff.tariff_schedule, destination_tariff)
    click_on("Delete")

    expect(page).to have_content("Destination tariff was successfully destroyed.")
    expect(page).to have_no_content(destination_tariff.id)
  end
end
