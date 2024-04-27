class AddISOCountryCodeToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :iso_country_code, :string, null: false)
    add_index(:phone_numbers, :iso_country_code)
  end
end
