class CreateSentMessageSMSGateways < ActiveRecord::Migration[8.0]
  def change
    create_table :sent_message_sms_gateways, id: :uuid do |t|
      t.references :message, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.references :sms_gateway, null: false, foreign_key: true, type: :uuid, index: true

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
