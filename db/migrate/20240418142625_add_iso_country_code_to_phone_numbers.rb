class AddISOCountryCodeToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :iso_country_code, :string)

    reversible do |dir|
      dir.up do
        PhoneNumber.includes(:carrier).find_each do |phone_number|
          beneficiary = Beneficiary.new(
            phone_number: phone_number.number,
            fallback_country: phone_number.carrier.country
          )

          country = beneficiary.valid? ? beneficiary.country : phone_number.carrier.country

          phone_number.update_columns(iso_country_code: country.alpha2)
        end
      end
    end

    change_column_null(:phone_numbers, :iso_country_code, false)
    add_index(:phone_numbers, :iso_country_code)
  end
end
