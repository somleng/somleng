class OptimizeSlowIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index(
      :phone_calls,
      [ :status, :initiated_at, :sequence_number ],
      order: { sequence_number: :desc },
      where: "last_heartbeat_at IS NULL",
      algorithm: :concurrently,
      if_exists: true
    )

    add_index(
      :phone_calls,
      [ :status, :sequence_number, :initiated_at ],
      order: { sequence_number: :desc },
      where: "last_heartbeat_at IS NULL",
      algorithm: :concurrently,
      if_not_exists: true
    )

    add_index(
      :messages,
      [ :account_id, :sequence_number ],
      order: { sequence_number: :desc },
      algorithm: :concurrently,
      if_not_exists: true
    )

    remove_index(
      :phone_calls,
      :sequence_number,
      name: "index_phone_calls_on_sequence_number_for_stale_heartbeats",
      order: { sequence_number: :desc },
      where: "status IN ('initiated', 'ringing', 'answered')",
      algorithm: :concurrently,
      if_exists: true
    )

    add_index(
      :phone_calls,
      [ :sequence_number, :last_heartbeat_at ],
      order: { sequence_number: :desc },
      where: "status IN ('initiated', 'ringing', 'answered') AND last_heartbeat_at IS NOT NULL",
      name: "index_phone_calls_on_sequence_number_for_stale_heartbeats",
      algorithm: :concurrently,
      if_not_exists: true
    )

    remove_index(
      :phone_calls,
      [ :status, :region ],
      algorithm: :concurrently,
      if_exists: true
    )

    add_index(
      :phone_calls,
      [ :status, :region ],
      where: "status = 'queued'",
      algorithm: :concurrently,
      if_not_exists: true
    )

    remove_index(
      :phone_calls,
      [ :status, :initiating_at ],
      algorithm: :concurrently,
      if_exists: true
    )

    add_index(
      :phone_calls,
      [ :status, :initiating_at ],
      where: "status = 'initiating'",
      algorithm: :concurrently,
      if_not_exists: true
    )

    add_index(:phone_calls,
      [ :status, :id, :created_at ],
      where: "status = 'queued' AND initiation_queued_at IS NULL",
      algorithm: :concurrently,
      if_not_exists: true
    )

    remove_index(
      :messages,
      :account_id,
      algorithm: :concurrently,
      if_exists: true
    )

    remove_index(
      :phone_calls,
      :account_id,
      algorithm: :concurrently,
      if_exists: true
    )

    remove_index(
      :phone_calls,
      :sip_trunk_id,
      algorithm: :concurrently,
      if_exists: true
    )

    remove_index(
      :phone_calls,
      :region,
      where: { status: :queued },
      algorithm: :concurrently,
      if_exists: true
    )

    remove_index(
      :phone_calls,
      [ :status, :created_at, :initiation_queued_at ],
      where: { status: :queued },
      algorithm: :concurrently,
      if_exists: true
    )
  end
end
