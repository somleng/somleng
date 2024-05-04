require "rails_helper"

module CallService
  RSpec.describe Client do
    describe "#end_call" do
      it "ends a call" do
        client = Client.new
        phone_call_id = SecureRandom.uuid
        stub_request(:delete, %r{http://10.10.1.13}).to_return(status: 204)

        client.end_call(id: phone_call_id, host: "10.10.1.13")

        expect(WebMock).to have_requested(:delete, "http://10.10.1.13/calls/#{phone_call_id}")
      end
    end

    describe "#add_permission" do
      it "Authorizes the IP" do
        sqs_client = Aws::SQS::Client.new(stub_responses: true)
        client = Client.new(sqs_client:)

        client.add_permission("175.100.7.240")

        authorize_rule_request = sqs_client.api_requests.first
        expect(authorize_rule_request).to match(
          sqs_request(
            "175.100.7.240",
            job_class: "CreateOpenSIPSPermissionJob"
          )
        )
      end
    end

    describe "#remove_permission" do
      it "Revokes the IP" do
        sqs_client = Aws::SQS::Client.new(stub_responses: true)
        client = Client.new(sqs_client:)

        client.remove_permission("175.100.7.240")

        authorize_rule_request = sqs_client.api_requests.first
        expect(authorize_rule_request).to match(
          sqs_request(
            "175.100.7.240",
            job_class: "DeleteOpenSIPSPermissionJob"
          )
        )
      end
    end

    describe "#create_subscriber" do
      # username="user1"
      # password="password"
      # realm="somleng.org"
      # input="$username:$realm:$password"

      # md5_hash=$(echo -n "$input" | md5sum | head -c 32)
      # sha256_hash=$(echo -n "$input" | sha256sum | head -c 64)
      # sha512_hash=$(echo -n "$input" | sha512sum | head -c 64)

      it "creates a subscriber" do
        sqs_client = Aws::SQS::Client.new(stub_responses: true)
        client = Client.new(sqs_client:)

        client.create_subscriber(username: "user1", password: "password")

        create_subscriber_request = sqs_client.api_requests.first
        expect(create_subscriber_request).to match(
          sqs_request(
            {
              username: "user1",
              md5_password: "e4e073a5123b081c2282fc4846c85c62",
              sha256_password: "0c09363da899fa201ed5896eeb41ca99ea15290e0c439e4f19b78e05000f7b2b",
              sha512_password: "e559890001280978339003dc204fcd4d722c3908eea55493d5443906e15d084d"
            },
            job_class: "CreateOpenSIPSSubscriberJob"
          )
        )
      end
    end

    describe "#delete_subscriber" do
      it "deletes a subscriber" do
        sqs_client = Aws::SQS::Client.new(stub_responses: true)
        client = Client.new(sqs_client:)

        client.delete_subscriber(username: "user1")

        delete_subscriber_request = sqs_client.api_requests.first
        expect(delete_subscriber_request).to match(
          sqs_request(
            { username: "user1" },
            job_class: "DeleteOpenSIPSSubscriberJob"
          )
        )
      end
    end

    def sqs_request(*args)
      options = args.extract_options!
      job_class = options.fetch(:job_class)

      hash_including(
        operation_name: :send_message,
        params: hash_including(
          queue_url: AppSettings.config_for(:call_service_queue_url),
          message_body: {
            job_class:,
            job_args: args
          }.to_json
        )
      )
    end
  end
end
