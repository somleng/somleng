module RequestHelpers
  # def do_request(method, path, body = {}, headers = {}, options = {})
  #   public_send(method, path, { params: body, headers: authorization_headers.merge(headers) }.merge(options))
  # end
  #
  # def authorization_headers
  #   { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(http_basic_auth_user, http_basic_auth_password) }
  # end
  #
  # def assert_unauthorized!
  #   expect(response.body).to be_present
  #   expect(response.code).to eq("401")
  # end
  #
  # def assert_not_found!
  #   expect(response.code).to eq("404")
  #   expect(response.body).to be_present
  #   expect(JSON.parse(response.body)["status"]).to eq(404)
  # end
  #
  # def assert_invalid_request!
  #   expect(response.code).to eq("422")
  #   expect(response.body).to be_present
  #   expect(JSON.parse(response.body)["status"]).to eq(422)
  # end
  #
  # def account
  #   @account ||= create(:account, *account_traits.keys, account_params)
  # end
  #
  # def account_traits
  #   { with_access_token: nil }
  # end
  #
  # def account_params
  #   {}
  # end
  #
  # def http_basic_auth_user
  #   account.sid
  # end
  #
  # def http_basic_auth_password
  #   account.auth_token
  # end
  #
  # def account_sid
  #   account.sid
  # end

  def parsed_response_body
    JSON.parse(response.body)
  end

  def build_api_authorization_headers(account)
    build_authorization_headers(account.sid, account.auth_token)
  end

  def build_internal_api_authorization_headers
    build_authorization_headers("user", "password")
  end

  def build_authorization_headers(username, password)
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
