class DeleteSIPTrunk < ApplicationWorkflow
  attr_reader :sip_trunk, :call_service_client

  delegate :username, to: :sip_trunk

  def initialize(sip_trunk, **options)
    @sip_trunk = sip_trunk
    @call_service_client = options.fetch(:call_service_client) { CallService::Client.new }
  end

  def call
    delete_subscriber if username.present?
  end

  private

  def delete_subscriber
    call_service_client.delete_subscriber(username:)
  end
end
