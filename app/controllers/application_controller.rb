class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_carrier
  helper_method :app_request

  private

  def current_carrier
    @current_carrier ||= app_request.find_carrier!
  end

  def app_request
    AppRequest.new(request)
  end
end
