class FixAddingPartialIndexesOnPhoneCallsForExpiringQueries < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index(
      :phone_calls,
      [ :sequence_number, :last_heartbeat_at ],
      order: { sequence_number: :desc },
      where: "status IN ('initiated', 'ringing', 'answered')"
    )

    remove_index(
      :phone_calls,
      [ :sequence_number, :initiated_at ],
      order: { sequence_number: :desc },
      where: "status IN ('initiated', 'ringing', 'answered') AND last_heartbeat_at IS NULL"
    )

    add_index :phone_calls,
      [ :status, :initiated_at, :sequence_number ],
      order: { sequence_number: :desc },
      where: "last_heartbeat_at IS NULL",
      algorithm: :concurrently
  end
end
