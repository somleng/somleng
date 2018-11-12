module RequestHelpers
  def parsed_response_body
    JSON.parse(response.body)
  end

  def build_api_authorization_headers(account)
    build_authorization_headers(account.sid, account.auth_token)
  end

  def build_internal_api_authorization_headers
    build_authorization_headers(
      Rails.configuration.app_settings.fetch("internal_api_http_auth_user"),
      Rails.configuration.app_settings.fetch("internal_api_http_auth_password")
    )
  end

  def build_authorization_headers(username, password)
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
