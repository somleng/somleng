class RevokeSecurityGroupIP < ApplicationWorkflow
  attr_reader :security_group_id, :ip, :client

  def initialize(params)
    @security_group_id = params.fetch(:security_group_id)
    @ip = params.fetch(:ip)
    @client = params.fetch(:client) { Aws::EC2::Client.new }
  end

  def call
    client.revoke_security_group_ingress(
      group_id: security_group_id,
      ip_permissions: [
        {
          ip_protocol: "UDP",
          from_port: sip_port,
          to_port: sip_port,
          ip_ranges: [
            {
              cidr_ip: "#{ip}/32"
            }
          ]
        }
      ]
    )
  rescue Aws::EC2::Errors::InvalidPermissionNotFound => e
    Rails.logger.warn("#{e.message} - IP: #{ip}")
  end

  private

  def sip_port
    Rails.configuration.app_settings.fetch(:sip_port)
  end
end
