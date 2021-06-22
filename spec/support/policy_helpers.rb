module PolicyHelpers
  def build_user_context_for_carrier(role:, carrier: nil)
    carrier ||= build_stubbed(:carrier)
    user = build_stubbed(:user, :carrier, role, carrier: carrier)
    organization = build_stubbed(:organization, organization: carrier)
    build_stubbed(:user_context, user: user, current_organization: organization)
  end

  def build_user_context_for_account(params)
    params[:account] ||= build_stubbed(:account)
    params[:user] ||= build_stubbed(:user)
    params[:account_membership] ||= build_stubbed(
      :account_membership,
      params.fetch(:role, :owner),
      user: params.fetch(:user),
      account: params.fetch(:account)
    )
    organization = build_stubbed(:organization, organization: params.fetch(:account))
    build_stubbed(
      :user_context,
      user: params.fetch(:account_membership).user,
      current_organization: organization,
      current_account_membership: params.fetch(:account_membership)
    )
  end
end

RSpec.configure do |config|
  config.include PolicyHelpers, type: :policy
end
