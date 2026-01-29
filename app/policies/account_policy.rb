class AccountPolicy < ApplicationPolicy
  delegate :carrier_managed?, :customer_managed?, to: :record

  def read?
    user.carrier_user?
  end

  def show_auth_token?
    read? && carrier_managed?
  end

  def manage?
    carrier_admin?
  end

  def destroy?
    super && carrier_managed? && record.messages.blank? && record.phone_calls.blank?
  end
end
