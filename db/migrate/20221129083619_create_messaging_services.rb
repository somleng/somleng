class CreateMessagingServices < ActiveRecord::Migration[7.0]
  def change
    create_table :messaging_services, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :carrier, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :status_callback_url
      t.string :inbound_request_url
      t.string :inbound_request_method
      t.boolean :smart_encoding, null: false, default: false
      t.boolean :use_inbound_webhook_on_number, null: false, default: true

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
