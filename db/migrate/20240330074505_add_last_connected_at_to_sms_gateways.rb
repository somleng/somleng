class AddLastConnectedAtToSMSGateways < ActiveRecord::Migration[7.1]
  def change
    add_column(:sms_gateways, :last_connected_at, :datetime)
    add_index(:sms_gateways, :last_connected_at)
  end
end
