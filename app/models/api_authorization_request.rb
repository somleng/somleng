class APIAuthorizationRequest
  JWT_PATTERN = /\A[\w-]+\.[\w-]+\.[\w-]*\z/.freeze

  attr_reader :request

  def self.call(request)
    new(request).validate
  end

  def initialize(request)
    @request = request
  end

  def validate
    return if authorization_token.blank?
    return authorization_token unless jwt_token?

    JWTAuthorizationRequest.new(request).validate
  end

  def jwt_token?
    authorization_token.match?(JWT_PATTERN)
  end

  private

  def authorization_token
    Doorkeeper::OAuth::Token.from_bearer_authorization(request)
  end

  class JWTAuthorizationRequest
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def validate
      return if authorization_token.blank?

      api_token = payload["api_token"]
      timestamp = payload.fetch("timestamp", 0).to_i

      return if Time.zone.at(timestamp) < 5.minutes.ago

      verify!(api_token)

      api_token
    rescue JWT::DecodeError
    end

    private

    def authorization_token
      @authorization_token ||= Doorkeeper::OAuth::Token.from_bearer_authorization(request)
    end

    def payload
      @payload ||= JWT.decode(authorization_token, nil, false).first
    end

    def verify!(api_token)
      return unless (access_token = find_access_token(api_token))

      settings = OAuthApplicationSettings.find_by!(oauth_application_id: access_token.application_id)
      JWT.decode(
        authorization_token,
        OpenSSL::PKey::RSA.new(settings.public_key),
        true,
        algorithm: "RS256"
      )
    end

    def find_access_token(token)
      Doorkeeper.config.access_token_model.by_token(token)
    end
  end
end
