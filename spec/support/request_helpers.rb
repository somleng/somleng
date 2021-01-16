module RequestHelpers
  def json_response
    JSON.parse(response.body)
  end

  def parsed_response_body
    JSON.parse(response.body)
  end

  def build_api_authorization_headers(account)
    build_authorization_headers(account.id, account.auth_token)
  end

  def build_authorization_headers(username, password)
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
