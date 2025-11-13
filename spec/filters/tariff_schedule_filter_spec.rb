require "rails_helper"

RSpec.describe TariffScheduleFilter do
  it "filters by the tariff plan id" do
    carrier = create(:carrier)
    plan = create(:tariff_plan, carrier:)
    schedule = create(:tariff_schedule, carrier:)
    create(:tariff_plan_tier, plan:, schedule:)
    create(:tariff_schedule, carrier:)

    expect(
      TariffScheduleFilter.new(
        resources_scope: carrier.tariff_schedules,
        input_params: { filter: { tariff_plan_id: plan.id } }
      ).apply
    ).to contain_exactly(schedule)
  end

  it "filters by destination group" do
    carrier = create(:carrier)
    schedule = create(:tariff_schedule, carrier:)
    destination_tariff = create(:destination_tariff, schedule:)
    create(:tariff_schedule, carrier:)

    expect(
      TariffScheduleFilter.new(
        resources_scope: carrier.tariff_schedules,
        input_params: { filter: { destination_group_id: destination_tariff.destination_group_id } }
      ).apply
    ).to contain_exactly(schedule)
  end
end
