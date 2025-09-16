class AddDeviceTypeToSMSGateways < ActiveRecord::Migration[8.0]
  def change
    add_column :sms_gateways, :device_type, :string

    reversible do |dir|
      dir.up do
        SMSGateway.where(device_type: nil).update_all(device_type: "gateway")
      end
    end

    change_column_null :sms_gateways, :device_type, false
  end
end
