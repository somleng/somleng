class CreateSIPTrunk < ApplicationWorkflow
  attr_reader :sip_trunk, :call_service_client

  delegate :inbound_source_ip, :region, :username, :password, to: :sip_trunk

  def initialize(sip_trunk, **options)
    @sip_trunk = sip_trunk
    @call_service_client = options.fetch(:call_service_client) { CallService::Client.new }
  end

  def call
    authorize_inbound_source_ip if inbound_source_ip.present?
    create_subscriber if username.present?
  end

  private

  def authorize_inbound_source_ip
    call_service_client.add_permission(inbound_source_ip, group_id: region.group_id)
  end

  def create_subscriber
    call_service_client.create_subscriber(username:, password:)
  end
end
