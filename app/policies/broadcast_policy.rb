class BroadcastPolicy < ApplicationPolicy
  delegate :carrier_managed?, :customer_managed?, to: :record

  def read?
    FeatureFlag.enabled_for?(user, :broadcasts)
  end

  def manage?
    read?
  end
end
