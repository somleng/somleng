class OptimizePhoneCallsStaleHeartbeatQuery < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index(
      :phone_calls,
      [ :status, :last_heartbeat_at ],
      algorithm: :concurrently
    )

    add_index(
      :phone_calls,
      :sequence_number,
      name: "index_phone_calls_on_sequence_number_for_stale_heartbeats",
      order: { sequence_number: :desc },
      where: "status IN ('initiated', 'ringing', 'answered')",
      algorithm: :concurrently
    )
  end
end
