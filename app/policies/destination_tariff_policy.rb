class DestinationTariffPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
