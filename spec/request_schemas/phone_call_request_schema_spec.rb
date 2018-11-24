require "rails_helper"

RSpec.describe PhoneCallRequestSchema, type: :request_schema do
  it { expect(validate_schema(To: nil)).not_to have_valid_field(:To) }
  it { expect(validate_schema(To: "+8559723456789")).not_to have_valid_field(:To) }
  it { expect(validate_schema(To: "+855 97 2345 678")).to have_valid_field(:To) }
  it { expect(validate_schema(To: "+855972345678")).to have_valid_field(:To) }

  it { expect(validate_schema(From: nil)).not_to have_valid_field(:From) }
  it { expect(validate_schema(From: "abcd")).not_to have_valid_field(:From) }
  it { expect(validate_schema(From: "1234")).to have_valid_field(:From) }
  it { expect(validate_schema(From: "+1234")).to have_valid_field(:From) }

  it { expect(validate_schema(Url: nil)).not_to have_valid_field(:Url) }
  it { expect(validate_schema(Url: "http://localhost:5000")).not_to have_valid_field(:Url) }
  it { expect(validate_schema(Url: "foo-bar")).not_to have_valid_field(:Url) }
  it { expect(validate_schema(Url: "http://demo.twilio.com/docs/voice.xml")).to have_valid_field(:Url) }
  it { expect(validate_schema(Url: "https://scfm.somleng.org/api/remote_phone_call_events")).to have_valid_field(:Url) }

  it { expect(validate_schema(Method: nil)).not_to have_valid_field(:Method) }
  it { expect(validate_schema).to have_valid_field(:Method) }
  it { expect(validate_schema(Method: "head")).not_to have_valid_field(:Method) }
  it { expect(validate_schema(Method: "post")).to have_valid_field(:Method) }
  it { expect(validate_schema(Method: "get")).to have_valid_field(:Method) }
  it { expect(validate_schema(Method: "POST")).to have_valid_field(:Method) }
  it { expect(validate_schema(Method: "GET")).to have_valid_field(:Method) }

  it { expect(validate_schema(StatusCallback: nil)).not_to have_valid_field(:StatusCallback) }
  it { expect(validate_schema).to have_valid_field(:StatusCallback) }
  it { expect(validate_schema(StatusCallback: "http://localhost:5000")).not_to have_valid_field(:StatusCallback) }
  it { expect(validate_schema(StatusCallback: "http://demo.twilio.com/docs/voice.xml")).to have_valid_field(:StatusCallback) }

  it { expect(validate_schema(StatusCallbackMethod: nil)).not_to have_valid_field(:StatusCallbackMethod) }
  it { expect(validate_schema).to have_valid_field(:StatusCallbackMethod) }
  it { expect(validate_schema(StatusCallbackMethod: "HEAD")).not_to have_valid_field(:StatusCallbackMethod) }
  it { expect(validate_schema(StatusCallbackMethod: "POST")).to have_valid_field(:StatusCallbackMethod) }
end
