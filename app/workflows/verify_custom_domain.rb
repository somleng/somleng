class VerifyCustomDomain < ApplicationWorkflow
  attr_reader :custom_domain

  def initialize(custom_domain)
    @custom_domain = custom_domain
  end

  def call
    custom_domain.touch(:verification_started_at)
  end
end
