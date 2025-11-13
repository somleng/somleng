class CreateTariffPackagePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :tariff_package_plans, id: :uuid do |t|
      t.references :package, null: false, foreign_key: { to_table: :tariff_packages, on_delete: :cascade }, type: :uuid
      t.references :plan, null: false, foreign_key: { to_table: :tariff_plans, on_delete: :cascade }, type: :uuid
      t.string :category, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:tariff_package_plans, [ :package_id, :category ], unique: true)
  end
end
