class AccountPolicy < ApplicationPolicy
  delegate :carrier_managed?, :customer_managed?, to: :record

  def read?
    user.carrier_user?
  end

  def manage?
    carrier_admin?
  end

  def destroy?
    super && carrier_managed? && !record.messages.exists? && !record.phone_calls.exists?
  end
end
