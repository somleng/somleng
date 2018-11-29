module API
  module Internal
    class BaseController < API::BaseController
      skip_before_action :doorkeeper_authorize!, :authorize_account!
      http_basic_authenticate_with(
        name: Rails.configuration.app_settings.fetch("internal_api_http_auth_user"),
        password: Rails.configuration.app_settings.fetch("internal_api_http_auth_password")
      )
    end
  end
end
