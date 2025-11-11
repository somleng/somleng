require "rails_helper"

RSpec.describe TariffCalculation do
  it "returns the correct destination tariff" do
    carrier = create(:carrier)
    standard_plan = create(:tariff_plan, :outbound_messages, carrier:)
    promo_plan = create(:tariff_plan, :outbound_messages, carrier:)
    standard_schedule = create(:tariff_schedule, :outbound_messages, carrier:)
    promo_schedule = create(:tariff_schedule, :outbound_messages, carrier:)
    create(
      :tariff_plan,
      tariff_plan: standard_plan,
      tariff_schedule: standard_schedule,
      weight: 10
    )
    create(
      :tariff_plan,
      tariff_plan: promo_plan,
      tariff_schedule: standard_schedule,
      weight: 10
    )
    create(
      :tariff_plan,
      tariff_plan: promo_plan,
      tariff_schedule: promo_schedule,
      weight: 20
    )
    destination_group = create(:destination_group, carrier:, prefixes: [ "855" ])

    exception_tariff = create(
      :destination_tariff,
      tariff_schedule: standard_schedule,
      destination_group: create(:destination_group, carrier:, prefixes: [ "85597" ])
    )
    promo_tariff = create(
      :destination_tariff,
      tariff_schedule: promo_schedule,
      destination_group:
    )
    standard_tariff = create(
      :destination_tariff,
      tariff_schedule: standard_schedule,
      destination_group:
    )
    catch_all_tariff = create(
      :destination_tariff,
      tariff_schedule: standard_schedule,
      destination_group: create(:destination_group, :catch_all, carrier:)
    )

    expect(
      TariffCalculation.new(
        tariff_plan: standard_plan,
        destination: "855975100888"
      ).calculate
    ).to eq(exception_tariff)

    expect(
      TariffCalculation.new(
        tariff_plan: promo_plan,
        destination: "855975100888"
      ).calculate
    ).to eq(exception_tariff)

    expect(
      TariffCalculation.new(
        tariff_plan: standard_plan,
        destination: "85510510888"
      ).calculate
    ).to eq(standard_tariff)

    expect(
      TariffCalculation.new(
        tariff_plan: promo_plan,
        destination: "85510510888"
      ).calculate
    ).to eq(promo_tariff)

    expect(
      TariffCalculation.new(
        tariff_plan: standard_plan,
        destination: "856975100888"
      ).calculate
    ).to eq(catch_all_tariff)

    expect(
      TariffCalculation.new(
        tariff_plan: promo_plan,
        destination: "856975100888"
      ).calculate
    ).to eq(catch_all_tariff)
  end
end
