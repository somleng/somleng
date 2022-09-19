require "rails_helper"

module CallService
  RSpec.describe Client do
    describe "#add_permission" do
      it "Authorizes the IP" do
        sqs_client = Aws::SQS::Client.new(stub_responses: true)
        client = Client.new(sqs_client:)

        client.add_permission("175.100.7.240")

        authorize_rule_request = sqs_client.api_requests.first
        expect(authorize_rule_request).to match(
          aws_request(
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
          aws_request(
            "175.100.7.240",
            job_class: "DeleteOpenSIPSPermissionJob"
          )
        )
      end
    end

    def aws_request(*args)
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
