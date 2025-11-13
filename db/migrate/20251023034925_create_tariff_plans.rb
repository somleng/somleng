class CreateTariffPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :tariff_plans, id: :uuid do |t|
      t.references :carrier, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.citext :name, null: false
      t.string :category, null: false
      t.text :description
      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:tariff_plans, [ :carrier_id, :category, :name ], unique: true)
  end
end
