class AddSenderIDBehaviorToSMSGateways < ActiveRecord::Migration[8.1]
  def change
    rename_column(:sms_gateways, :default_sender, :sender_id)
    add_column(:sms_gateways, :sender_id_behavior, :string)
    add_column(:messages, :sender_id, :string)

    reversible do |dir|
      dir.up do
        SMSGateway.where(sender_id: nil).update_all(sender_id_behavior: :passthrough)
        SMSGateway.where.not(sender_id: nil).update_all(sender_id_behavior: :fallback)
        Message.where.not(from: nil).update_all('"sender_id" = "from"')
      end
    end

    change_column_null(:sms_gateways, :sender_id_behavior, false)
  end
end
