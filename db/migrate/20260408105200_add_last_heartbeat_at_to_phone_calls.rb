class AddLastHeartbeatAtToPhoneCalls < ActiveRecord::Migration[8.1]
  def change
    add_column(:phone_calls, :last_heartbeat_at, :datetime)
    add_index(:phone_calls, [:status, :last_heartbeat_at])
  end
end
