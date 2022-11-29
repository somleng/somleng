class CreateMessagingServiceSenders < ActiveRecord::Migration[7.0]
  def change
    create_table :messaging_service_senders, id: :uuid do |t|
      t.references(
        :phone_number,
        type: :uuid,
        null: false,
        foreign_key: { on_delete: :cascade },
        index: { unique: true }
      )
      t.references(
        :messaging_service,
        type: :uuid,
        null: false,
        foreign_key: { on_delete: :cascade }
      )

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
