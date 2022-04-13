class PhoneNumberPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    super && record.account_id.blank?
  end

  def release?
    manage? && record.account_id.present?
  end

  def manage?
    carrier_admin?
  end
end
