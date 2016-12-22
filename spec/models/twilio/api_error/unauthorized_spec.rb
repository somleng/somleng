require 'rails_helper'

describe Twilio::ApiError::Unauthorized do
  let(:asserted_hash) {
    {
      "code" => 20003,
      "detail" => "Your AccountSid or AuthToken was incorrect.",
      "more_info" => "https://www.twilio.com/docs/errors/20003",
      "message" => "Authentication Error - invalid username",
      "status" => 401
    }
  }

  include_examples("twilio_api_error")
end
