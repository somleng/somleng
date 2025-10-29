class CreateTariffPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :tariff_plans, id: :uuid do |t|
      t.references :tariff_package, null: false, foreign_key: { on_delete: :cascade }, type: :uuid, index: false
      t.references :tariff_schedule, null: false, foreign_key: { on_delete: :cascade }, type: :uuid, index: false
      t.decimal :weight, null: false, precision: 8, scale: 2
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:tariff_plans, [ :tariff_package_id, :tariff_schedule_id ], unique: true)
    add_index(:tariff_plans, [ :tariff_package_id, :tariff_schedule_id, :weight ])
  end
end
