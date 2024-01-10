class CreateVerifications < ActiveRecord::Migration[7.1]
  def change
    create_table :verifications, id: :uuid do |t|
      t.references :verification_service,
                   type: :uuid, null: false,
                   foreign_key: { on_delete: :nullify }

      t.references :account,
                   type: :uuid,
                   null: false,
                   foreign_key: { on_delete: :nullify }

      t.references :carrier,
                   type: :uuid,
                   null: false

      t.string :to, null: false
      t.string :channel, null: false
      t.string :status, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.datetime :approved_at
      t.datetime :canceled_at

      t.timestamps
    end
  end
end
