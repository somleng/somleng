module RequestHelpers
  def json_response(body = response_body)
    JSON.parse(body)
  end

  def jsonapi_response_attributes
    json_response.dig("data", "attributes")
  end

  def build_api_authorization_headers(account)
    build_authorization_headers(account.id, account.auth_token)
  end

  def build_authorization_headers(username, password)
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end

  def set_twilio_api_authorization_header(account)
    set_authorization_header(username: account.id, password: account.auth_token)
  end

  def set_authorization_header(username:, password:)
    authentication(:basic, ActionController::HttpAuthentication::Basic.encode_credentials(username, password))
  end

  def set_carrier_api_authorization_header(carrier)
    oauth_application = create(:oauth_application, :carrier, owner: carrier)
    access_token = create(:oauth_access_token, application: oauth_application, scopes: :carrier_api)
    authentication :basic, "Bearer #{access_token.token}"
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
  config.before(:each, type: :request) do
    host! "api.somleng.org"
  end
end
