class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :verify_custom_domain!

  helper_method :custom_domain_request
  helper_method :carrier_from_custom_domain

  private

  def verify_custom_domain!
    return unless custom_domain_request.custom_domain_request?

    custom_domain_request.find_custom_domain!(:dashboard)
  end

  def custom_domain_request
    @custom_domain_request ||= CustomDomainRequest.new(request)
  end

  def carrier_from_custom_domain
    custom_domain_request.find_custom_domain(:dashboard)&.carrier
  end
end
