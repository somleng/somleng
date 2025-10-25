class CreateAccountBillingProfileTariffPackageLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :account_billing_profile_tariff_package_line_items, id: :uuid do |t|
      t.references :account_billing_profile, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :tariff_package, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :category, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:account_billing_profile_tariff_package_line_items, [ :account_billing_profile_id, :category ], unique: true)
  end
end
