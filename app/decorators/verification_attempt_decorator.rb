class VerificationAttemptDecorator < SimpleDelegator
  def status
    successful? ? "successful" : "failed"
  end
end
