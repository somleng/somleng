class CheckVerificationCode < ApplicationWorkflow
  attr_reader :verification, :code

  def initialize(verification:, code:)
    @verification = verification
    @code = code
  end

  def call
    ApplicationRecord.transaction do
      verification_attempt = create_verification_attempt
      approve_verification if verification_attempt.successful?
    end

    verification
  end

  private

  def create_verification_attempt
    VerificationAttempt.create!(verification:, code:)
  end

  def approve_verification
    verification.approve!
  end
end
