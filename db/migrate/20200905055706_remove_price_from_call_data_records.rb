class RemovePriceFromCallDataRecords < ActiveRecord::Migration[6.0]
  def change
    remove_column(:call_data_records, :price_microunits)
    remove_column(:call_data_records, :price_currency)
  end
end
