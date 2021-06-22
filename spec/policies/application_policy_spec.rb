require "rails_helper"

RSpec.describe ApplicationPolicy do
  it "has a default policy" do
    user_context = build_stubbed(:user_context)

    policy = ApplicationPolicy.new(user_context)

    expect(policy.index?).to eq(true)
    expect(policy.show?).to eq(true)
    expect(policy.read?).to eq(true)
    expect(policy.new?).to eq(false)
    expect(policy.create?).to eq(false)
    expect(policy.edit?).to eq(false)
    expect(policy.update?).to eq(false)
    expect(policy.destroy?).to eq(false)
    expect(policy.manage?).to eq(false)
  end
end
