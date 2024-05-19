class AddLocalityAndRegionToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :iso_region_code, :citext)
    add_index(:phone_numbers, :iso_region_code)
    add_column(:phone_numbers, :locality, :citext)
    add_index(:phone_numbers, :locality)
  end
end
