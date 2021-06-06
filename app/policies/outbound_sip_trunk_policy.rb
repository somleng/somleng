class OutboundSIPTrunkPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def read?
    user.current_organization.carrier?
  end
end
