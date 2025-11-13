require "rails_helper"

RSpec.describe TariffPlanFilter do
  it "filters by the tariff schedule id" do
    carrier = create(:carrier)
    plan = create(:tariff_plan, carrier:)
    schedule = create(:tariff_schedule, carrier:)
    create(:tariff_plan_tier, plan:, schedule:)
    create(:tariff_plan, carrier:)

    expect(
      TariffPlanFilter.new(
        resources_scope: carrier.tariff_plans,
        input_params: { filter: { tariff_schedule_id: schedule.id } }
      ).apply
    ).to contain_exactly(plan)
  end
end
