class AddSMSGatewayIDAndSIPTrunkIDToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_reference(:phone_numbers, :sms_gateway, type: :uuid, foreign_key: { on_delete: :nullify })
    add_reference(:phone_numbers, :sip_trunk, type: :uuid, foreign_key: { on_delete: :nullify })
  end
end
