class UserInvitationPolicy < ApplicationPolicy
  def update?
    (carrier_admin? || account_owner?) && !record.accepted_or_not_invited?
  end
end
