class CreateMessageSendRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :message_send_requests, id: :uuid do |t|
      t.references :message, null: true, foreign_key: { on_delete: :nullify }, type: :uuid, index: { unique: true }
      t.references :sms_gateway, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
