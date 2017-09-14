require 'rails_helper'

RSpec.describe TwilioHttpClientRequest do
  describe "#execute!(request)" do
    let(:somleng_twilio_http_client_request_double) {
      instance_double(Somleng::TwilioHttpClient::Request)
    }

    def assert_timeout!
      allow(somleng_twilio_http_client_request_double).to receive(:execute!).and_raise(timeout_error)
      expect(somleng_twilio_http_client_request_double).to receive(:execute!)
      subject.execute!(somleng_twilio_http_client_request_double)
    end

    context "Net::ReadTimeout" do
      let(:timeout_error) { Net::ReadTimeout }
      it { assert_timeout! }
    end

    context "Net::OpenTimeout" do
      let(:timeout_error) { Net::OpenTimeout }
      it { assert_timeout! }
    end
  end
end

