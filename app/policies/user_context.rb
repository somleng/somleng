class UserContext < SimpleDelegator
  attr_reader :current_organization, :current_account_membership

  def initialize(user, current_organization, current_account_membership)
    super(user)

    @current_organization = current_organization
    @current_account_membership = current_account_membership
  end
end
