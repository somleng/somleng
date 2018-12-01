require "webmock/rspec"

WebMock.disable_net_connect!

# From: https://gist.github.com/2596158
# Thankyou Bartosz Blimke!
# https://twitter.com/bartoszblimke/status/198391214247124993

module LastRequest
  def clear_requests!
    @requests = nil
  end

  def requests
    @requests ||= []
  end

  def last_request=(request_signature)
    requests << request_signature
    request_signature
  end

  def request_params(request)
    WebMock::Util::QueryMapper.query_to_values(request.body)
  end
end

WebMock.extend(LastRequest)
WebMock.after_request do |request_signature, _response|
  WebMock.last_request = request_signature
end

RSpec.configure do |config|
  config.before do
    WebMock.reset!
  end
end
