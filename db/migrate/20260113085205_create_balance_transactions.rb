class CreateBalanceTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :balance_transactions, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :carrier, null: false, foreign_key: true, type: :uuid
      t.references :created_by, null: true, foreign_key: { to_table: :users, on_delete: :nullify }, type: :uuid
      t.references :message, null: true, foreign_key: { on_delete: :nullify }, type: :uuid, index: { unique: true }
      t.references :phone_call, null: true, foreign_key: { on_delete: :nullify }, type: :uuid, index: { unique: true }
      t.string :type, null: false, index: true
      t.decimal :amount_cents, null: false, precision: 12, scale: 4
      t.string :currency, null: false
      t.string :charge_category, null: true, index: true
      t.text :description, null: true
      t.bigint :external_id, null: true, index: { unique: true, order: :desc }

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end
  end
end
