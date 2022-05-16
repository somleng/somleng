module CustomDomainAPIAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :verify_custom_domain!
  end

  private

  def verify_custom_domain!
    return unless custom_domain_request.custom_domain_request?

    custom_domain_request.find_custom_domain!(:api, carrier: authorized_carrier)
  end

  def custom_domain_request
    @custom_domain_request ||= CustomDomainRequest.new(request)
  end
end