class VerificationAttempt < ApplicationRecord
  belongs_to :verification, counter_cache: true
end
