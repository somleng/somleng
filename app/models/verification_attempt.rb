class VerificationAttempt < ApplicationRecord
  belongs_to :verification, counter_cache: true

  encrypts :code

  def successful?
    ActiveSupport::SecurityUtils.secure_compare(
      code,
      verification.code
    )
  end
end
