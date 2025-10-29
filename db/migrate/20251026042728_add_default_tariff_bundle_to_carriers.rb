class AddDefaultTariffBundleToCarriers < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :carriers,
      :default_tariff_bundle,
      null: true,
      type: :uuid,
      foreign_key: {
        to_table: :tariff_bundles,
        on_delete: :nullify
      }
    )
  end
end
