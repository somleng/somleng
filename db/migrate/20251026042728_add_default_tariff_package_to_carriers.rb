class AddDefaultTariffPackageToCarriers < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :carriers,
      :default_tariff_package,
      null: true,
      type: :uuid,
      foreign_key: {
        to_table: :tariff_packages,
        on_delete: :nullify
      }
    )
  end
end
