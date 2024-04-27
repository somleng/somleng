class AddAreaCodeToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :area_code, :string)
    add_index(:phone_numbers, :area_code)

    reversible do |dir|
      dir.up do
        PhoneNumber.find_each do |phone_number|
          phone_number.update_columns(area_code: phone_number.number.area_code)
        end
      end
    end
  end
end
