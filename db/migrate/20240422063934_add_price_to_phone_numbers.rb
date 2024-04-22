class AddPriceToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :price_cents, :integer)
    add_column(:phone_numbers, :currency, :string)

    reversible do |dir|
      dir.up do
        PhoneNumber.update_all(price_cents: 0)
        execute <<-SQL
          UPDATE phone_numbers
          SET currency = carriers.billing_currency
          FROM carriers where carriers.id = phone_numbers.carrier_id
        SQL
      end
    end

    change_column_null(:phone_numbers, :price_cents, false)
    change_column_null(:phone_numbers, :currency, false)
  end
end
