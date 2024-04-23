class AddISOCountryCodeToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :iso_country_code, :string)

    reversible do |dir|
      dir.up do
        PhoneNumber.includes(:carrier).find_each do |phone_number|
          phone_number.update_columns(
            iso_country_code: (phone_number.number.e164? ? ResolvePhoneNumberCountry.call(phone_number.number, fallback_country: phone_number.carrier.country) : phone_number.carrier.country).alpha2
          )
        end
      end
    end

    change_column_null(:phone_numbers, :iso_country_code, false)
    add_index(:phone_numbers, :iso_country_code)
  end
end
