class DestinationGroupPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def update?
    !record.catch_all?
  end
end
