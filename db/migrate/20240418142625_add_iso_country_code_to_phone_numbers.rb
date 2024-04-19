class AddISOCountryCodeToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :iso_country_code, :string)

    reversible do |dir|
      dir.up do
        PhoneNumber.includes(:carrier).find_each do |phone_number|
          number = PhoneNumberParser.parse(phone_number.number)

          country = if number.country_code.present?
            ResolvePhoneNumberCountry.call(number, fallback_country: phone_number.carrier.country)
          else
            phone_number.carrier.country
          end

          phone_number.update_columns(iso_country_code: country.alpha2)
        end
      end
    end

    change_column_null(:phone_numbers, :iso_country_code, false)
    add_index(:phone_numbers, :iso_country_code)
  end
end
