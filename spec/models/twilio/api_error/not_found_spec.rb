require "rails_helper"

describe Twilio::APIError::NotFound do
  subject { described_class.new(request_url: request_url) }

  let(:request_url) { "/some/path.json" }

  let(:asserted_hash) do
    {
      "code" => 20_404,
      "more_info" => "https://www.twilio.com/docs/errors/20404",
      "message" => "The requested resource /some/path.json was not found",
      "status" => 404
    }
  end

  include_examples("twilio_api_error")
end
