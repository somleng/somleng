module RequestHelpers
  def json_response
    JSON.parse(response.body)
  end

  def build_api_authorization_headers(account)
    build_authorization_headers(account.id, account.auth_token)
  end

  def build_authorization_headers(username, password)
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end

  def set_api_authorization_header(account)
    set_authorization_header(username: account.id, password: account.auth_token)
  end

  def set_authorization_header(username:, password:)
    authentication(:basic, ActionController::HttpAuthentication::Basic.encode_credentials(username, password))
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
