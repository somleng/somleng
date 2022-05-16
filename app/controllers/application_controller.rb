class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :verify_custom_domain!

  helper_method :app_request
  helper_method :carrier_from_custom_domain

  private

  def verify_custom_domain!
    return unless app_request.custom_domain_request?

    app_request.find_custom_domain!(:dashboard)
  end

  def app_request
    @app_request ||= AppRequest.new(request)
  end

  def carrier_from_custom_domain
    app_request.find_custom_domain(:dashboard)&.carrier
  end
end
