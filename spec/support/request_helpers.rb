module RequestHelpers
  def json_response(body = response_body)
    JSON.parse(body)
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
    rsa_key = OpenSSL::PKey::RSA.generate(2048)
    oauth_application = create(:oauth_application, :carrier, owner: carrier)
    access_token = create(:oauth_access_token, application: oauth_application, scopes: :carrier_api)
    create(
      :oauth_application_settings,
      oauth_application: oauth_application,
      public_key: rsa_key.public_key
    )

    set_jwt_authorization_header(access_token.token, rsa_key)
  end

  def set_jwt_authorization_header(token, rsa_key)
    jwt = JWT.encode(
      {
        "api_token": token,
        "timestamp": Time.current.to_i.to_s
      },
      rsa_key,
      "RS256"
    )

    authentication :basic, "Bearer #{jwt}"
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
