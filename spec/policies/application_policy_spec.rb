require "rails_helper"

RSpec.describe ApplicationPolicy do
  it "authorizes members" do
    user = build_stubbed(:user, :member)

    policy = ApplicationPolicy.new(user)

    expect(policy.index?).to eq(true)
    expect(policy.show?).to eq(true)
    expect(policy.new?).to eq(false)
    expect(policy.create?).to eq(false)
    expect(policy.edit?).to eq(false)
    expect(policy.update?).to eq(false)
    expect(policy.destroy?).to eq(false)
    expect(policy.manage?).to eq(false)
  end

  it "authorizes admin" do
    user = build_stubbed(:user, :admin)

    policy = ApplicationPolicy.new(user)

    expect(policy.index?).to eq(true)
    expect(policy.show?).to eq(true)
    expect(policy.new?).to eq(true)
    expect(policy.create?).to eq(true)
    expect(policy.edit?).to eq(true)
    expect(policy.update?).to eq(true)
    expect(policy.destroy?).to eq(true)
    expect(policy.manage?).to eq(true)
  end
end
