require "rails_helper"

RSpec.describe CarrierUserPolicy, type: :policy do
  it "denies access to users managing themselves" do
    user = build_stubbed(:user, :owner)

    policy = CarrierUserPolicy.new(user, user)

    expect(policy.update?).to eq(false)
    expect(policy.destroy?).to eq(false)
  end

  it "grants access to carrier owners" do
    carrier = create(:carrier)
    user = create(:user, :owner, carrier:)
    managed_user = create(:user, carrier:)

    policy = CarrierUserPolicy.new(user, managed_user)

    expect(policy.update?).to eq(true)
    expect(policy.destroy?).to eq(true)
  end

  it "denies access to carrier admins" do
    user = create(:user, :admin)

    policy = CarrierUserPolicy.new(user)

    expect(policy.index?).to eq(true)
    expect(policy.create?).to eq(false)
  end
end
