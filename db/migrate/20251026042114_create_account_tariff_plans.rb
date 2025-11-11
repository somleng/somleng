class CreateAccountTariffPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :account_tariff_plans, id: :uuid do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :tariff_plan, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :category, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:account_tariff_plans, [ :account_id, :category ], unique: true)
  end
end
