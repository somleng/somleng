require "rails_helper"

RSpec.describe InboundSIPTrunkAuthorization do
  it "Authorizes the IP" do
    client = Aws::SQS::Client.new(stub_responses: true)
    inbound_sip_trunk_authorization = InboundSIPTrunkAuthorization.new(client:)

    inbound_sip_trunk_authorization.add_permission("175.100.7.240")

    authorize_rule_request = client.api_requests.first
    expect(authorize_rule_request).to match(
      aws_request(
        ip: "175.100.7.240",
        job_class: "CreateOpenSIPSPermissionJob"
      )
    )
  end

  it "Revokes the IP" do
    client = Aws::SQS::Client.new(stub_responses: true)
    inbound_sip_trunk_authorization = InboundSIPTrunkAuthorization.new(client:)

    inbound_sip_trunk_authorization.remove_permission("175.100.7.240")

    authorize_rule_request = client.api_requests.first
    expect(authorize_rule_request).to match(
      aws_request(
        ip: "175.100.7.240",
        job_class: "DeleteOpenSIPSPermissionJob"
      )
    )
  end

  def aws_request(ip:, job_class:)
    hash_including(
      operation_name: :send_message,
      params: hash_including(
        queue_url: AppSettings.config_for(:switch_services_queue_url),
        message_body: {
          job_class:,
          job_args: [ip]
        }.to_json
      )
    )
  end
end
