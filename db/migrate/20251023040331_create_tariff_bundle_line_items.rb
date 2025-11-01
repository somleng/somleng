class CreateTariffBundleLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :tariff_bundle_line_items, id: :uuid do |t|
      t.references :tariff_bundle, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :tariff_package, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :category, null: false

      t.bigserial :sequence_number, null: false, index: { unique: true, order: :desc }

      t.timestamps
    end

    add_index(:tariff_bundle_line_items, [ :tariff_bundle_id, :category ], unique: true)
  end
end
