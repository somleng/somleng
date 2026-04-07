class AddSwitchProxyIdentifierToPhoneCalls < ActiveRecord::Migration[8.1]
  def change
    add_column(:phone_calls, :switch_proxy_identifier, :string)
    add_column(:phone_calls, :last_heartbeat_at, :datetime)
    add_index(:phone_calls, :switch_proxy_identifier, unique: true)
    add_index(:phone_calls, :last_heartbeat_at)
  end
end
