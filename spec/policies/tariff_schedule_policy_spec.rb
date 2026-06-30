require "rails_helper"

RSpec.describe TariffSchedulePolicy, type: :policy do
  it "denies access for destroying tariff schedules other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :member, carrier:)
    tariff_schedule = build_stubbed(:tariff_schedule, carrier:)

    policy = TariffSchedulePolicy.new(user, tariff_schedule)

    expect(policy).to be_read
    expect(policy).not_to be_manage
  end

  it "denies access for destroying tariff schedules with plan tiers" do
    user = build_stubbed(:user, :carrier)
    tariff_schedule = create(:tariff_schedule)
    create(:tariff_plan_tier, schedule: tariff_schedule)

    policy = TariffSchedulePolicy.new(user, tariff_schedule)

    expect(policy).not_to be_destroy
  end

  it "denies access tariff schedules other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :customer, carrier:)
    tariff_schedule = build_stubbed(:tariff_schedule, carrier:)

    policy = TariffSchedulePolicy.new(user, tariff_schedule)

    expect(policy).not_to be_read
    expect(policy).not_to be_manage
    expect(policy).not_to be_destroy
  end
end
