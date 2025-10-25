class DestinationGroupPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
