class VerifyCustomDomainJob < ApplicationJob
  def perform(*args)
    VerifyCustomDomain.call(*args)
  end

  rescue_from(ActiveJob::DeserializationError) do |e|
    Rails.logger.warn(e.message)
  end
end
