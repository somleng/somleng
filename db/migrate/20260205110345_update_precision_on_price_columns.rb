class UpdatePrecisionOnPriceColumns < ActiveRecord::Migration[8.1]
  def change
    change_column(:phone_calls, :price_cents, :decimal, precision: 14, scale: 4)
    change_column(:messages, :price_cents, :decimal, precision: 14, scale: 4)
    change_column(:tariffs, :rate_cents, :decimal, precision: 14, scale: 4)
  end
end
