class AddTypeToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :type, :string)

    reversible do |dir|
      dir.up do
        PhoneNumber.find_each do |phone_number|
          number = PhoneNumberParser.parse(phone_number.number)
          if number.e164?
            if phone_number.carrier_id == "76507e8a-ab93-4adb-a19b-dc304d84d36c" || phone_number.number.starts_with?("1")
              phone_number.update_columns(type: "local")
            else
              phone_number.update_columns(type: "mobile")
            end
          else
            phone_number.update_columns(type: "short_code")
          end
        end
      end
    end

    change_column_null(:phone_numbers, :type, false)
    add_index(:phone_numbers, :type)
  end
end
