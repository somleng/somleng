class AddPriceAndPriceUnitToPhoneCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :phone_calls, :price, :decimal, precision: 10, scale: 4
    add_column :phone_calls, :price_unit, :string
  end
end
