class CreateCallTariffs < ActiveRecord::Migration[8.0]
  def change
    create_table :call_tariffs, id: :uuid do |t|
      t.references :tariff, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.decimal :per_minute_rate_cents, null: false, precision: 10, scale: 4, default: 0
      t.decimal :connection_fee_cents, null: false, precision: 10, scale: 4, default: 0
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
