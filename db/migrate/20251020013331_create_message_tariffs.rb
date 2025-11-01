class CreateMessageTariffs < ActiveRecord::Migration[8.0]
  def change
    create_table :message_tariffs, id: :uuid do |t|
      t.references :tariff, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.decimal :rate_cents, null: false, precision: 10, scale: 4, default: 0
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
