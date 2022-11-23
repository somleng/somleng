class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :carrier, type: :uuid, null: false, foreign_key: true
      t.references :phone_number, type: :uuid, foreign_key: { on_delete: :nullify }
      t.references :sms_gateway, type: :uuid, foreign_key: { on_delete: :nullify }
      t.integer :channel
      t.text :body, null: false
      t.integer :segments, null: false
      t.string :to, null: false
      t.string :from, null: false
      t.string :direction, null: false
      t.string :status, null: false
      t.string :status_callback_url
      t.string :status_callback_method
      t.string :beneficiary_country_code, null: false
      t.string :beneficiary_fingerprint, null: false
      t.string :error_code
      t.string :error_message
      t.datetime :sent_at
      t.decimal :price, precision: 10, scale: 4
      t.string :price_unit

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end