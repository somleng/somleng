class AddExternalIDToCallDataRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :call_data_records, :external_id, :string, null: true
    add_index :call_data_records, :external_id, unique: true
  end
end
