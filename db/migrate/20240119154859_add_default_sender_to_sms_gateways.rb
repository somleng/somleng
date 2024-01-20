class AddDefaultSenderToSMSGateways < ActiveRecord::Migration[7.1]
  def change
    add_reference(:sms_gateways, :default_sender, type: :uuid, foreign_key: { to_table: :phone_numbers, on_delete: :nullify })
  end
end
