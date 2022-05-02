class RemoveOldRefileFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :call_data_records, :file_id, :string
    remove_column :call_data_records, :file_filename, :string
    remove_column :call_data_records, :file_size, :integer
    remove_column :call_data_records, :file_content_type, :string
  end
end
