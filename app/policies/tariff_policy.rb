class TariffPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
