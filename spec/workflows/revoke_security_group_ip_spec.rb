require "rails_helper"

RSpec.describe RevokeSecurityGroupIP do
  it "Revokes the IP" do
    client = Aws::EC2::Client.new(stub_responses: true)

    RevokeSecurityGroupIP.call(
      security_group_id: "security-group-id",
      ip: "175.100.7.240",
      client: client
    )

    revoke_rule_request = client.api_requests.first
    expect(revoke_rule_request).to match(
      aws_request(
        operation_name: :revoke_security_group_ingress,
        security_group_id: "security-group-id",
        ip_ranges: {
          cidr_ip: "175.100.7.240/32"
        }
      )
    )
  end

  it "Handles the rule not existing" do
    client = Aws::EC2::Client.new(stub_responses: true)
    client.stub_responses(:revoke_security_group_ingress, "InvalidPermissionNotFound")

    expect {
      RevokeSecurityGroupIP.call(
        security_group_id: "security-group-id",
        ip: "175.100.7.240",
        client: client
      )
    }.not_to raise_error
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
