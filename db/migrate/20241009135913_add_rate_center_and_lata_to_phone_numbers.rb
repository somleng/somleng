class AddRateCenterAndLATAToPhoneNumbers < ActiveRecord::Migration[7.2]
  def change
    add_column(:phone_numbers, :rate_center, :citext)
    add_column(:phone_numbers, :lata, :string)
    add_index(:phone_numbers, :rate_center)
    add_index(:phone_numbers, :lata)
  end
end
