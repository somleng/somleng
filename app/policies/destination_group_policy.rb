class DestinationGroupPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def update?
    !record.catch_all?
  end

  def destroy?
    record.destination_tariffs.empty?
  end
end
