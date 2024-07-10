class RemoveCallLegFromCallDataRecords < ActiveRecord::Migration[7.1]
  def change
    remove_column(:call_data_records, :call_leg, :string)
    remove_index(:call_data_records, :phone_call_id)
    add_index(:call_data_records, :phone_call_id, unique: true)
  end
end
