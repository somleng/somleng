require "rails_helper"

RSpec.describe TariffPlanPolicy, type: :policy do
  it "denies access for destroying tariff plans with subscriptions" do
    user = build_stubbed(:user, :carrier)
    tariff_plan = create(:tariff_plan)
    create(:tariff_plan_subscription, plan: tariff_plan)

    policy = TariffPlanPolicy.new(user, tariff_plan)

    expect(policy).not_to be_destroy
  end
end
