class RemovePriceFromCallDataRecords < ActiveRecord::Migration[6.0]
  def change
    remove_column(:call_data_records, :price_microunits)
    remove_column(:call_data_records, :price_currency)
    remove_column(:call_data_records, :file_id)
    remove_column(:call_data_records, :file_filename)
    remove_column(:call_data_records, :file_size)
    remove_column(:call_data_records, :file_content_type)
  end
end
