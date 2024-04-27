class AccountPolicy < ApplicationPolicy
  delegate :carrier_managed?, :customer_managed?, to: :record

  def index?
    read?
  end

  def read?
    user.carrier_user?
  end

  def show_auth_token?
    read? && carrier_managed?
  end

  def manage?
    carrier_admin?
  end
end
