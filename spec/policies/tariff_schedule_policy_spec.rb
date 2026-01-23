require "rails_helper"

RSpec.describe TariffSchedulePolicy, type: :policy do
  it "denies access for destroying tariff schedules with plan tiers" do
    user = build_stubbed(:user, :carrier)
    tariff_schedule = create(:tariff_schedule)
    create(:tariff_plan_tier, schedule: tariff_schedule)

    policy = TariffSchedulePolicy.new(user, tariff_schedule)

    expect(policy).not_to be_destroy
  end
end
