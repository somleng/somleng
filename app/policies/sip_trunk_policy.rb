class SIPTrunkPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def read?
    managing_carrier?
  end
end
