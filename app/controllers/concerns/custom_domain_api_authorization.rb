module CustomDomainAPIAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :verify_custom_domain!
  end

  private

  def verify_custom_domain!
    return unless app_request.custom_domain_request?

    app_request.find_custom_domain!(:api, carrier: authorized_carrier)
  end

  def app_request
    @app_request ||= AppRequest.new(request)
  end
end
