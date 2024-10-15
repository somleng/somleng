class UpdateDefaultSenderOnSMSGateways < ActiveRecord::Migration[7.2]
  def change
    add_column(:sms_gateways, :default_sender, :string)
    add_index(:sms_gateways, :default_sender)
    remove_reference(:sms_gateways, :default_sender, type: :uuid, foreign_key: { to_table: :phone_numbers, on_delete: :nullify })
  end
end
