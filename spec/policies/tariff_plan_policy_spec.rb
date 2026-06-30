require "rails_helper"

RSpec.describe TariffPlanPolicy, type: :policy do
  it "denies access for destroying tariff plans other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :member, carrier:)
    tariff_plan = build_stubbed(:tariff_plan, carrier:)

    policy = TariffPlanPolicy.new(user, tariff_plan)

    expect(policy).to be_read
    expect(policy).not_to be_manage
  end

  it "denies access for destroying tariff plans with subscriptions" do
    user = build_stubbed(:user, :carrier)
    tariff_plan = create(:tariff_plan)
    create(:tariff_plan_subscription, plan: tariff_plan)

    policy = TariffPlanPolicy.new(user, tariff_plan)

    expect(policy).not_to be_destroy
  end

  it "denies access tariff plans other than carrier admins" do
    carrier = build_stubbed(:carrier)
    user = build_stubbed(:user, :customer, carrier:)
    tariff_plan = build_stubbed(:tariff_plan, carrier:)

    policy = TariffPlanPolicy.new(user, tariff_plan)

    expect(policy).not_to be_read
    expect(policy).not_to be_manage
    expect(policy).not_to be_destroy
  end
end
