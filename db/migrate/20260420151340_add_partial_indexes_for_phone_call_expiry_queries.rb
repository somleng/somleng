class AddPartialIndexesForPhoneCallExpiryQueries < ActiveRecord::Migration[8.1]
def change
    # Optimization for calls with stale heartbeats
    add_index(
      :phone_calls,
      [ :sequence_number, :last_heartbeat_at ],
      order: { sequence_number: :desc },
      where: "status IN ('initiated', 'ringing', 'answered')"
    )

    # Optimization for calls that never had a heartbeat
    add_index(
      :phone_calls,
      [ :sequence_number, :initiated_at ],
      order: { sequence_number: :desc },
      where: "status IN ('initiated', 'ringing', 'answered') AND last_heartbeat_at IS NULL"
    )
  end
end
