class Users::InvitationsController < Devise::InvitationsController
  private

  def accept_resource
    user = super
    if user.errors.empty? && user.current_account_membership.blank?
      user.update!(current_account_membership: user.account_memberships.first)
    end
    user
  end
end
