class AddSenderIDBehaviorToSMSGateways < ActiveRecord::Migration[8.1]
  def change
    rename_column(:sms_gateways, :default_sender, :sender_id)
    add_column(:sms_gateways, :sender_id_behavior, :string, null: false)
    rename_column(:sip_trunks, :default_sender, :caller_id)
    add_column(:sip_trunks, :caller_id_behavior, :string, null: false)
    add_column(:messages, :sender_id, :string)
  end
end
