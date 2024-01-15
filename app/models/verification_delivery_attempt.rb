class VerificationDeliveryAttempt < ApplicationRecord
  extend Enumerize

  enumerize :channel, in: Verification.channel.values, predicates: true

  belongs_to :verification, counter_cache: :delivery_attempts_count
  belongs_to :message, optional: true
  belongs_to :phone_call, optional: true

  def deliverable
    message || phone_call
  end
end
