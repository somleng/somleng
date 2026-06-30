require "rails_helper"

RSpec.describe TariffPlanPolicy, type: :policy do
  it "denies access for destroying tariff plans with subscriptions" do
    user = build_stubbed(:user, :carrier)
    tariff_plan = create(:tariff_plan)
    create(:tariff_plan_subscription, plan: tariff_plan)

    policy = TariffPlanPolicy.new(user, tariff_plan)

    expect(policy).not_to be_destroy
  end

  it "denies access for destroying tariff plans other than carrier admins" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :customer, carrier:)
    create(:account_membership, user:, account:)
    tariff_plan = create(:tariff_plan, carrier:)

    policy = TariffPlanPolicy.new(user, tariff_plan)

    expect(policy).not_to be_destroy
  end
end
