require "rails_helper"

RSpec.describe CarrierUserPolicy, type: :policy do
  it "denies access to users managing themselves" do
    user_context = build_user_context_for_carrier(role: :owner)

    policy = CarrierUserPolicy.new(user_context, user_context)

    expect(policy.update?).to eq(false)
    expect(policy.destroy?).to eq(false)
  end

  it "grants access to carrier owners" do
    carrier = create(:carrier)
    user_context = build_user_context_for_carrier(role: :owner, carrier: carrier)
    managed_user = create(:user, carrier: carrier)

    policy = CarrierUserPolicy.new(user_context, managed_user)

    expect(policy.update?).to eq(true)
    expect(policy.destroy?).to eq(true)
  end

  it "denies access to carrier admins" do
    user_context = build_user_context_for_carrier(role: :admin)

    policy = CarrierUserPolicy.new(user_context)

    expect(policy.index?).to eq(true)
    expect(policy.create?).to eq(false)
  end
end
