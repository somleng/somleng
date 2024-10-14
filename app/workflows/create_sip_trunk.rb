class CreateSIPTrunk < ApplicationWorkflow
  attr_reader :sip_trunk, :call_service_client

  delegate :inbound_source_ips, :region, :username, :password, to: :sip_trunk

  def initialize(sip_trunk, **options)
    @sip_trunk = sip_trunk
    @call_service_client = options.fetch(:call_service_client) { CallService::Client.new }
  end

  def call
    create_subscriber if username.present?
  end

  private

  def create_subscriber
    call_service_client.create_subscriber(username:, password:)
  end
end
