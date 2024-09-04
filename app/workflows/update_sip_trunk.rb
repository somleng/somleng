class UpdateSIPTrunk < ApplicationWorkflow
  attr_reader :sip_trunk, :call_service_client

  delegate :inbound_source_ip, :region, :username, :password, :previous_changes, to: :sip_trunk

  def initialize(sip_trunk, **options)
    @sip_trunk = sip_trunk
    @call_service_client = options.fetch(:call_service_client) { CallService::Client.new }
  end

  def call
    update_permission if attribute_changed?(:inbound_source_ip) || attribute_changed?(:region)
    update_subscriber if attribute_changed?(:username)
  end

  private

  def update_permission
    if attribute_changed?(:inbound_source_ip)
      previous_ip_address = previous_changes.fetch(:inbound_source_ip).first
      call_service_client.remove_permission(previous_ip_address) if previous_ip_address.present?
      call_service_client.add_permission(inbound_source_ip, group_id: region.group_id) if inbound_source_ip.present?
    elsif attribute_changed?(:region)
      call_service_client.update_permission(inbound_source_ip, group_id: region.group_id) if inbound_source_ip.present?
    end
  end

  def update_subscriber
    previous_username = previous_changes[:username].first
    call_service_client.delete_subscriber(username: previous_username)
    call_service_client.create_subscriber(username:, password:)
  end

  def attribute_changed?(attribute)
    previous_value, new_value = previous_changes[attribute]
    previous_value != new_value
  end
end
