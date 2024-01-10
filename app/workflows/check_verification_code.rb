class CheckVerificationCode < ApplicationWorkflow
  attr_reader :verification, :code

  def initialize(verification:, code:)
    @verification = verification
    @code = code
  end

  def call
    ApplicationRecord.transaction do
      create_verification_attempt
      approve_verification if attempt_valid?
    end

    verification
  end

  private

  def attempt_valid?
    ActiveSupport::SecurityUtils.secure_compare(
      code,
      verification.code
    )
  end

  def create_verification_attempt
    VerificationAttempt.create!(verification:, code:)
  end

  def approve_verification
    verification.approve!
  end
end
