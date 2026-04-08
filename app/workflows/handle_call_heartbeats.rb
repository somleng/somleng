class HandleCallHeartbeats < ApplicationWorkflow
  attr_reader :call_ids

  def initialize(call_ids)
    super()
    @call_ids = call_ids
  end

  def call
    PhoneCall
      .where(external_id: call_ids)
      .update_all(last_heartbeat_at: Time.current)
  end
end
