require "rails_helper"

RSpec.describe AuthorizeSecurityGroupIP do
  it "Authorizes the IP" do
    client = Aws::EC2::Client.new(stub_responses: true)

    AuthorizeSecurityGroupIP.call(
      security_group_id: "security-group-id",
      ip: "175.100.7.240",
      description: "Security Group Rule",
      client: client
    )

    authorize_rule_request = client.api_requests.first
    expect(authorize_rule_request).to match(
      aws_request(
        operation_name: :authorize_security_group_ingress,
        security_group_id: "security-group-id",
        ip_ranges: {
          cidr_ip: "175.100.7.240",
          description: "Security Group Rule"
        }
      )
    )
  end

  def aws_request(operation_name:, security_group_id:, ip_ranges:, ip_permissions: {})
    hash_including(
      operation_name: operation_name,
      params: hash_including(
        group_id: security_group_id,
        ip_permissions: [
          hash_including(
            ip_permissions.reverse_merge(
              from_port: 5060, to_port: 5060, ip_protocol: "UDP",
              ip_ranges: [hash_including(ip_ranges)]
            )
          )
        ]
      )
    )
  end
end
