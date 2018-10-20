class Api::Internal::BaseController < Api::BaseController
  skip_before_action :doorkeeper_authorize!, :authorize_account!
  http_basic_authenticate_with(
    name: Rails.configuration.twilreapi.fetch("internal_api_http_auth_user"),
    password: Rails.configuration.twilreapi.fetch("internal_api_http_auth_password")
  )
end
