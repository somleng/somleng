class UpdateSIPTrunk < ApplicationWorkflow
  attr_reader :sip_trunk, :call_service_client

  delegate :region, :username, :password, :previous_changes, to: :sip_trunk

  def initialize(sip_trunk, **options)
    @sip_trunk = sip_trunk
    @call_service_client = options.fetch(:call_service_client) { CallService::Client.new }
  end

  def call
    update_subscriber if attribute_changed?(:username)
  end

  private

  def update_subscriber
    previous_username = previous_changes[:username].first
    call_service_client.delete_subscriber(username: previous_username) if previous_username.present?
    call_service_client.create_subscriber(username:, password:) if username.present?
  end

  def attribute_changed?(attribute)
    previous_value, new_value = previous_changes[attribute]
    previous_value != new_value
  end
end
