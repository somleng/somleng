class CreateMessagingServiceAlphanumericSenderIds < ActiveRecord::Migration[8.1]
  def change
    create_table :messaging_service_alphanumeric_sender_ids, id: :uuid do |t|
      t.references(
        :sender_id,
        type: :uuid,
        null: false,
        foreign_key: {
          to_table: :alphanumeric_sender_ids,
          on_delete: :cascade
        }
      )
      t.references(
        :messaging_service,
        type: :uuid,
        null: false,
        foreign_key: {
          on_delete: :cascade
        },
        index: false
      )
      t.string(:destination_country_code, limit: 3)
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end

    add_index(
      :messaging_service_alphanumeric_sender_ids,
      [ :messaging_service_id, :destination_country_code ],
      unique: true,
      nulls_not_distinct: true
    )
  end
end
