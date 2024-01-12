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
      t.string :status, null: false, index: true
      t.string :code, null: false
      t.string :locale, null: false
      t.string :country_code, null: false
      t.integer :verification_attempts_count, null: false, default: 0
      t.integer :delivery_attempts_count, null: false, default: 0
      t.datetime :approved_at
      t.datetime :canceled_at
      t.datetime :expired_at, null: false, index: true

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end
  end
end
