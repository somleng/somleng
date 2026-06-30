class DestinationGroupPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def update?
    manage? && !record.catch_all?
  end

  def destroy?
    manage? && record.destination_tariffs.empty?
  end
end
