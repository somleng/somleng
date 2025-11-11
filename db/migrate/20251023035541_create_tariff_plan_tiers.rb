class CreateTariffPlanTiers < ActiveRecord::Migration[8.0]
  def change
    create_table :tariff_plan_tiers, id: :uuid do |t|
      t.references :tariff_plan, null: false, foreign_key: { on_delete: :cascade }, type: :uuid, index: false
      t.references :tariff_schedule, null: false, foreign_key: { on_delete: :cascade }, type: :uuid, index: false
      t.decimal :weight, null: false, precision: 8, scale: 2
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:tariff_plan_tiers, [ :tariff_plan_id, :tariff_schedule_id ], unique: true)
    add_index(:tariff_plan_tiers, [ :tariff_plan_id, :weight ], unique: true)
  end
end
