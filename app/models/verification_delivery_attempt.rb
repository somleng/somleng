class VerificationDeliveryAttempt < ApplicationRecord
  extend Enumerize

  enumerize :channel, in: Verification.channel.values, predicates: true

  belongs_to :verification, counter_cache: :delivery_attempts_count
  belongs_to :message, optional: true
end
