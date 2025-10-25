class CreateAccountBillingProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :account_billing_profiles, id: :uuid do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :tariff_bundle, null: true, foreign_key: { on_delete: :nullify }, type: :uuid
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end
  end
end
