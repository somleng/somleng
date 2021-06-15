module PolicyHelpers
  def build_user_context_for_carrier(role:, carrier: nil)
    carrier ||= build_stubbed(:carrier)
    user = build_stubbed(:user, :carrier, role, carrier: carrier)
    organization = build_stubbed(:organization, organization: carrier)
    build_stubbed(:user_context, user: user, current_organization: organization)
  end

  def build_user_context_for_account(role:, account: nil)
    account ||= build_stubbed(:account)
    user = build_stubbed(:user)
    account_membership = build_stubbed(:account_membership, role, user: user, account: account)
    organization = build_stubbed(:organization, organization: account)
    build_stubbed(
      :user_context,
      user: user,
      current_organization: organization,
      current_account_membership: account_membership
    )
  end
end

RSpec.configure do |config|
  config.include PolicyHelpers, type: :policy
end
