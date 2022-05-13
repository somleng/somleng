class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :verify_custom_domain!

  private

  def verify_custom_domain!
    return unless custom_domain_request.custom_domain_request?

    CustomDomain.verified.find_by!(
      host: custom_domain_request.custom_domain_hostname,
      type: :dashboard
    )
  end

  def custom_domain_request
    @custom_domain_request ||= CustomDomainRequest.new(request)
  end
end
