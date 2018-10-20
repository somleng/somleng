class Api::Internal::BaseController < Api::BaseController
  skip_before_action :api_authorize!
  http_basic_authenticate_with(
    name: Rails.configuration.twilreapi.fetch("internal_api_http_auth_user"),
    password: Rails.configuration.twilreapi.fetch("internal_api_http_auth_password")
  )
end
