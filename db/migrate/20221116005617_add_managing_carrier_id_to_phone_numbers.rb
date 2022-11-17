class AddManagingCarrierIDToPhoneNumbers < ActiveRecord::Migration[7.0]
  def change
    add_reference(
      :phone_numbers,
      :managing_carrier,
      type: :uuid,
      null: true,
      foreign_key: { to_table: :carriers }
    )

    reversible do |dir|
      dir.up do
        PhoneNumber.update_all("managing_carrier_id = carrier_id")
      end
    end

    change_column_null(:phone_numbers, :managing_carrier_id, false)
  end
end
