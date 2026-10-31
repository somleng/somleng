class CreateAlphanumericSenderIds < ActiveRecord::Migration[8.1]
  def change
    create_table :alphanumeric_sender_ids, id: :uuid do |t|
      t.references :carrier, type: :uuid, null: false,  foreign_key: { on_delete: :cascade }
      t.references :account, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.citext :sender_id, null: false
      t.string :approval_status, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(
      :alphanumeric_sender_ids,
      [ :carrier_id, :sender_id ],
      unique: true,
      where: "approval_status = 'approved'"
    )

    add_index(:alphanumeric_sender_ids, [ :account_id, :sender_id ], unique: true)
  end
end
