class AddAreaCodeToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :area_code, :string)
    add_index(:phone_numbers, :area_code)
  end
end
