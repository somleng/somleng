class AddPriceToPhoneNumbers < ActiveRecord::Migration[7.1]
  def change
    add_column(:phone_numbers, :price_cents, :integer, null: false)
    add_column(:phone_numbers, :currency, :string, null: false)
    add_index(:phone_numbers, [ :price_cents, :currency ])
  end
end
