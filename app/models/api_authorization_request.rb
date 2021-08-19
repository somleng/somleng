class APIAuthorizationRequest
  attr_reader :request

  def self.call(request)
    new(request).validate
  end

  def initialize(request)
    @request = request
  end

  def validate
    authorization_token
  end

  private

  def authorization_token
    Doorkeeper::OAuth::Token.from_request(
      request,
      :from_bearer_authorization,
      ->(request) { from_basic_authorization_password(request) }
    )
  end

  def from_basic_authorization_password(request)
    pattern = /^Basic /i
    header = request.authorization
    return unless header&.match(pattern)

    encoded_header = header.gsub(pattern, "")
    Base64.decode64(encoded_header).split(/:/, 2).last
  end
end
