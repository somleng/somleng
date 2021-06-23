class AuthorizeSecurityGroupIP < ApplicationWorkflow
  attr_reader :security_group_id, :ip, :description, :client

  def initialize(params)
    @security_group_id = params.fetch(:security_group_id)
    @ip = params.fetch(:ip)
    @description = params.fetch(:description)
    @client = params.fetch(:client) { Aws::EC2::Client.new }
  end

  def call
    client.authorize_security_group_ingress(
      group_id: security_group_id,
      ip_permissions: [
        {
          ip_protocol: "UDP",
          from_port: 5060,
          to_port: 5060,
          ip_ranges: [
            {
              cidr_ip: "#{ip}/32",
              description: description
            }
          ]
        }
      ]
    )
  end
end
