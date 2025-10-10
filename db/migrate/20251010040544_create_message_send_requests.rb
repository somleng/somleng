class CreateMessageSendRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :message_send_requests, id: :uuid do |t|
      # messages can be deleted by the account owner
      # https://www.somleng.org/docs/twilio_api/#08-delete-a-message
      # but message_send_requests are tied to the device -> SMS Gateway -> Carrier
      # so when the account owner deletes a message we still want to keep the
      # relationship so we can run queries like: device.message_send_requests.count

      t.references :message, null: true, foreign_key: { on_delete: :nullify }, type: :uuid, index: { unique: true }
      t.references :device, null: false, foreign_key: { on_delete: :cascade, to_table: :action_push_native_devices }, type: :uuid

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
