class CreateBalanceTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :balance_transactions, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :carrier, null: false, foreign_key: true, type: :uuid
      t.references :created_by, null: true, foreign_key: { to_table: :users, on_delete: :nullify }, type: :uuid
      t.string :type, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.bigint :external_id, null: true, index: { unique: true, order: :desc }
      t.text :description, null: true

      t.index :type

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }
      t.timestamps
    end
  end
end
