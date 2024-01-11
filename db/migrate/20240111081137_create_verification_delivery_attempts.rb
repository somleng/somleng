class CreateVerificationDeliveryAttempts < ActiveRecord::Migration[7.1]
  def change
    create_table :verification_delivery_attempts, id: :uuid do |t|
      t.references :verification, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :message, type: :uuid, null: true, foreign_key: { on_delete: :nullify }
      t.references :phone_call, type: :uuid, null: true, foreign_key: { on_delete: :nullify }
      t.string :channel, null: false
      t.string :from, null: false
      t.string :to, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
