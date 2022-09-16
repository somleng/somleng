module InboundSourceIPCallbacks
  extend ActiveSupport::Concern

  included do
    after_create :authorize_inbound_source_ip
    after_destroy :revoke_inbound_source_ip
    after_update :update_inbound_source_ip

    attribute :inbound_sip_trunk_authorization, default: InboundSIPTrunkAuthorization.new
  end

  private

  def update_inbound_source_ip
    old_inbound_source_ip, new_inbound_source_ip = previous_changes[:inbound_source_ip]

    return if old_inbound_source_ip == new_inbound_source_ip

    revoke_inbound_source_ip(ip: old_inbound_source_ip)
    authorize_inbound_source_ip
  end

  def authorize_inbound_source_ip
    inbound_sip_trunk_authorization.add_permission(inbound_source_ip)
  end

  def revoke_inbound_source_ip(ip: inbound_source_ip)
    inbound_sip_trunk_authorization.remove_permission(ip)
  end
end
