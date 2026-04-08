class HandleCallHeartbeats < ApplicationWorkflow
  attr_reader :switch_proxy_identifiers

  def initialize(switch_proxy_identifiers)
    super()
    @switch_proxy_identifiers = switch_proxy_identifiers
  end

  def call
    PhoneCall
      .where(switch_proxy_identifier: switch_proxy_identifiers)
      .update_all(last_heartbeat_at: Time.current)
  end
end
