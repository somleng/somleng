class CreateAlphanumericSenderIds < ActiveRecord::Migration[8.1]
  def change
    create_table :alphanumeric_sender_ids, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false,  foreign_key: { on_delete: :cascade }, index: false
      t.references :account, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.citext :sender_id, null: false
      t.string :status, null: false
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :revoked_at

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(
      :alphanumeric_sender_ids,
      [ :carrier_id, :sender_id ],
      unique: true,
      where: "status = 'approved'"
    )

    add_index(:alphanumeric_sender_ids, [ :account_id, :sender_id ], unique: true)
    add_index(:alphanumeric_sender_ids, [ :carrier_id, :account_id, :status ])
  end
end
