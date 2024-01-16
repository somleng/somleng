class VerificationDeliveryAttemptDecorator < SimpleDelegator
  def status
    return "unknown" if deliverable.blank?

    deliverable.decorated.status
  end
end
