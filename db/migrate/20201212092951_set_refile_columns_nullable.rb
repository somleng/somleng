class SetRefileColumnsNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:call_data_records, :file_id, true)
    change_column_null(:call_data_records, :file_filename, true)
    change_column_null(:call_data_records, :file_size, true)
    change_column_null(:call_data_records, :file_content_type, true)
  end
end
