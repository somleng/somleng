class RemoveCallLegFromCallDataRecords < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        CallDataRecord.where(call_leg: "B").delete_all
      end
    end

    remove_column(:call_data_records, :call_leg)
  end
end
