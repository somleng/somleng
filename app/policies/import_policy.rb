class ImportPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def read?
    manage?
  end
end
