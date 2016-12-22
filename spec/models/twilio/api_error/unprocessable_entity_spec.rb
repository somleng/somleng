require 'rails_helper'

describe Twilio::ApiError::UnprocessableEntity do
  let(:asserted_hash) {
    {
      "status" => 422
    }
  }

  include_examples("twilio_api_error")
end
