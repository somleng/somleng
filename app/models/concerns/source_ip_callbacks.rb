module SourceIPCallbacks
  extend ActiveSupport::Concern

  included do
    after_create :authorize_source_ip
    after_destroy :revoke_source_ip
    after_update :update_source_ip

    attribute :inbound_sip_trunk_authorization, default: InboundSIPTrunkAuthorization.new
  end

  private

  def update_source_ip
    old_source_ip, new_source_ip = previous_changes[:source_ip]

    return if old_source_ip == new_source_ip

    revoke_source_ip(ip: old_source_ip)
    authorize_source_ip
  end

  def authorize_source_ip
    inbound_sip_trunk_authorization.add_permission(source_ip)
  end

  def revoke_source_ip(ip: source_ip)
    inbound_sip_trunk_authorization.remove_permission(ip)
  end
end
