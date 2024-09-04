class DeleteSIPTrunk < ApplicationWorkflow
  attr_reader :sip_trunk, :call_service_client

  delegate :inbound_source_ip, :username, to: :sip_trunk

  def initialize(sip_trunk, **options)
    @sip_trunk = sip_trunk
    @call_service_client = options.fetch(:call_service_client) { CallService::Client.new }
  end

  def call
    revoke_permission if inbound_source_ip.present?
    delete_subscriber if username.present?
  end

  private

  def revoke_permission
    call_service_client.remove_permission(inbound_source_ip)
  end

  def delete_subscriber
    call_service_client.delete_subscriber(username:)
  end
end
