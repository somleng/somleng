class AddCountryCodeToCarriers < ActiveRecord::Migration[6.1]
  def change
    add_column(:carriers, :country_code, :string, null: false)
  end
end
