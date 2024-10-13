class AddLatitudeAndLongitudeToPhoneNumbers < ActiveRecord::Migration[7.2]
  def change
    add_column(:phone_numbers, :latitude, :decimal, precision: 10, scale: 6)
    add_column(:phone_numbers, :longitude, :decimal, precision: 10, scale: 6)
    add_index(:phone_numbers, [ :latitude, :longitude ])
  end
end
