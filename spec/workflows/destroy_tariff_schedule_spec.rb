require "rails_helper"

RSpec.describe DestroyTariffSchedule do
  it "destroys a tariff schedule" do
    tariff_schedule = create(:tariff_schedule)
    client = instance_spy(RatingEngineClient)

    result = DestroyTariffSchedule.call(tariff_schedule, client:)

    expect(result).to be_truthy
    expect(tariff_schedule).to have_attributes(
      persisted?: false
    )
    expect(client).to have_received(:destroy_tariff_schedule).with(tariff_schedule)
  end

  it "handles validation errors" do
    tariff_schedule = create(:tariff_schedule)
    create(:tariff_plan_tier, schedule: tariff_schedule, carrier: tariff_schedule.carrier)
    client = instance_spy(RatingEngineClient)

    result = DestroyTariffSchedule.call(tariff_schedule, client:)

    expect(result).to be_falsey
    expect(tariff_schedule).to have_attributes(
      persisted?: true,
      plan_tiers: contain_exactly(
        have_attributes(
          persisted?: true
        )
      )
    )
    expect(client).not_to have_received(:destroy_tariff_schedule)
  end
end
