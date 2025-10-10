class CreateMessageSendRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :message_send_requests, id: :uuid do |t|
      # messages can be deleted by the account owner
      # https://www.somleng.org/docs/twilio_api/#08-delete-a-message
      # but message_send_requests are tied to: SMS Gateway -> Carrier
      # so when the account owner deletes a message we still want to keep the
      # relationship to the SMS Gateway.
      # Device is optional (for the sms-gateway node app we don't have a device)
      # but the message_end_request should still be linked to the SMS Gateway so we can do
      # sms_gateway.message_send_requests.count
      # if the SMS gateway is deleted then we can delete the send requests because this is managed
      # by the carrier

      t.references :message, null: true, foreign_key: { on_delete: :nullify }, type: :uuid, index: { unique: true }
      t.references :device, null: true, foreign_key: { on_delete: :cascade, to_table: :action_push_native_devices }, type: :uuid
      t.references :sms_gateway, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
