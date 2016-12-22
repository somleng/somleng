require 'rails_helper'

describe Twilio::ApiError::NotFound do
  let(:request_url) { "/some/path.json" }
  subject { described_class.new(:request_url => request_url) }

  let(:asserted_hash) {
    {
      "code" => 20404,
      "more_info" => "https://www.twilio.com/docs/errors/20404",
      "message" => "The requested resource /some/path.json was not found",
      "status" => 404
    }
  }

  include_examples("twilio_api_error")
end
