module SourceIPCallbacks
  extend ActiveSupport::Concern

  included do
    after_commit :authorize_source_ip, on: :create
    after_commit :revoke_source_ip, on: :destroy
    after_commit :update_source_ip, on: :update
  end

  private

  def update_source_ip
    old_source_ip, new_source_ip = previous_changes[:source_ip]

    return if old_source_ip == new_source_ip

    revoke_source_ip(ip: old_source_ip)
    authorize_source_ip
  end

  def authorize_source_ip(ip: source_ip)
    update_security_group_rule(
      "AuthorizeSecurityGroupIP",
      ip: ip.to_s,
      description: "#{carrier.name} - #{name}"
    )
  end

  def revoke_source_ip(ip: source_ip)
    update_security_group_rule("RevokeSecurityGroupIP", ip: ip.to_s)
  end

  def update_security_group_rule(type, params)
    return if Rails.configuration.app_settings[:inbound_sip_trunks_security_group_id].blank?

    ExecuteWorkflowJob.perform_later(
      type,
      security_group_id: Rails.configuration.app_settings.fetch(:inbound_sip_trunks_security_group_id),
      **params
    )
  end
end
