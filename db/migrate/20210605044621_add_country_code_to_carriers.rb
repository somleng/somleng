class AddCountryCodeToCarriers < ActiveRecord::Migration[6.1]
  def change
    add_column(:carriers, :country_code, :string)

    reversible do |dir|
      dir.up do
        Carrier.update_all(country_code: "KH")
      end
    end

    change_column_null(:carriers, :country_code, false)
  end
end
