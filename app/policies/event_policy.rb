class EventPolicy < ApplicationPolicy
  def read?
    managing_carrier?
  end
end
