class AddManagedByCarrierIDToPhoneNumbers < ActiveRecord::Migration[7.0]
  def change
    add_reference(
      :phone_numbers,
      :managed_by_carrier,
      type: :uuid,
      null: true,
      foreign_key: { to_table: :carriers }
    )

    reversible do |dir|
      dir.up do
        PhoneNumber.update_all("managed_by_carrier_id = carrier_id")
      end
    end

    change_column_null(:phone_numbers, :managed_by_carrier_id, false)
  end
end
