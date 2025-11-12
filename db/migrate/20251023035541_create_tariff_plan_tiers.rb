class CreateTariffPlanTiers < ActiveRecord::Migration[8.0]
  def change
    create_table :tariff_plan_tiers, id: :uuid do |t|
      t.references :plan, null: false, foreign_key: { to_table: :tariff_plans, on_delete: :cascade }, type: :uuid, index: false
      t.references :schedule, null: false, foreign_key: { to_table: :tariff_schedules, on_delete: :cascade }, type: :uuid, index: false
      t.decimal :weight, null: false, precision: 8, scale: 2
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:tariff_plan_tiers, [ :plan_id, :schedule_id ], unique: true)
    add_index(:tariff_plan_tiers, [ :plan_id, :weight ], unique: true)
  end
end
