require "rails_helper"

RSpec.describe TariffPlanTierPolicy, type: :policy do
  it "denies access for destroying tariff plan tiers other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :member, carrier:)
    tariff_plan_tier = build_stubbed(:tariff_plan_tier, carrier:)

    policy = TariffPlanTierPolicy.new(user, tariff_plan_tier)

    expect(policy).to be_read
    expect(policy).not_to be_manage
  end

  it "denies access tariff plan tiers other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :customer, carrier:)
    tariff_plan_tier = build_stubbed(:tariff_plan_tier, carrier:)

    policy = TariffPlanTierPolicy.new(user, tariff_plan_tier)

    expect(policy).not_to be_read
    expect(policy).not_to be_manage
    expect(policy).not_to be_destroy
  end
end
